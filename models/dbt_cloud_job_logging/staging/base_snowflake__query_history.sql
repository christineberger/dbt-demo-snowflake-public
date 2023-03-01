{{ config(
    materialized='incremental',
    unique_id='query_id',
    pre_hook=[
        {"sql": "{{ ensure_models_are_selected() }}", "transaction": false},
        "{{ create_regexp_replace_udf(this) }}",
        "{{ create_merge_objects_udf(this) }}"
    ],
    enabled=var('transfer_job_history_to_snowflake') 
) }}

with

source as (
    select * from {{ source('snowflake_account_usage', 'query_history') }}
    
    -- Using end_time ensures it captures items which haven't been completed
    -- Filtering to the current user ensures that we're only adding history items
    -- that are newly added from the user that was running the models
    where lower(user_name) = '{{ target.user | lower }}'
    {%- if is_incremental() %}
        and end_time > (select max(end_time) from {{ this }} where lower(user_name) = '{{ target.user | lower }}')
    {%- endif %}
),

cleanup as (
    select
        query_id,
        query_text,
        database_id,
        database_name,
        schema_id,
        schema_name,
        query_type,
        user_name,
        role_name,
        warehouse_name,
        query_tag,
        execution_status,
        error_code,
        error_message,
        start_time,
        end_time,
        total_elapsed_time,
        rows_produced,
        rows_inserted,
        rows_updated,
        rows_deleted,
        rows_unloaded,
        compilation_time,
        execution_time,
        queued_provisioning_time,

        -- this removes comments enclosed by /* <comment text> */ and 
        -- single line comments starting with -- and either ending with 
        -- a new line or end of string
        {{ this.database }}.{{ this.schema }}.job_logging_regexp_replace(
            query_text, 
            $$(/\*(.|\n|\r)*?\*/)|(--.*$)|(--.*(\n|\r))$$,
             ''
        )  as query_text_no_comments,


        try_parse_json(regexp_substr(query_text, '/\\*\\s({"app":\\s"dbt".*})\\s\\*/', 1, 1, 'ie')) as _dbt_json_comment_meta,
        
        case
            when try_parse_json(query_tag)['dbt_snowflake_query_tags_version'] is not null 
            then try_parse_json(query_tag)
        end as _dbt_json_query_tag_meta,
        
        case
            when _dbt_json_comment_meta is not null or _dbt_json_query_tag_meta is not null 
            then {{ this.database }}.{{ this.schema }}.job_logging_merge_objects(
                coalesce(_dbt_json_comment_meta, {}), 
                coalesce(_dbt_json_query_tag_meta, {})
            )
        end as dbt_metadata
    from source
),

filter_and_extract_jobs as (
    select
        -- Note: This needs to be set up within your environment variables
        -- from Deploy > Environments > Environment Variables. You only need
        -- to set the default here as every environment will have the same
        -- value.
        '{{ env_var("DBT_CLOUD_ACCOUNT_ID") }}' as dbt_cloud_account_id,
        dbt_metadata['dbt_cloud_job_id']::string as dbt_cloud_job_id,
        dbt_metadata['dbt_cloud_project_id']::string as dbt_cloud_project_id,
        dbt_metadata['dbt_cloud_run_id']::string as dbt_cloud_run_id,
        dbt_metadata['dbt_cloud_run_reason']::string as dbt_cloud_run_reason,
        dbt_metadata['node_name']::string as dbt_job_node_name,
        dbt_metadata['node_resource_type']::string as dbt_job_node_resource_type,
        *    
    from cleanup
    -- Only things sent from a dbt cloud job run
    where dbt_metadata['dbt_cloud_run_id'] is not null
)

select * from filter_and_extract_jobs
order by start_time