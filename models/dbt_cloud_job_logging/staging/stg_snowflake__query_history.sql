{{ config(
    materialized='incremental',
    pre_hook=["{{ create_regexp_replace_udf(this) }}", "{{ create_merge_objects_udf(this) }}"],
    enabled=var('tranfer_job_history_to_snowflake')
) }}

with

source as (
    select * from {{ source('snowflake_account_usage', 'query_history') }}

    -- limiting the returned information to tagged queries
    -- (which happens on model build with dbt-snowflake-query-tag package)
    -- and only those made by the user.
    -- We will filter this further later.
    where query_tag != ''

    {%- if is_incremental() %}
    -- must use end time in case query hasn't completed
    and end_time > (select max(end_time) from {{ this }})
    {%- endif %}
),

transformed as (
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
)

select * from transformed        
order by start_time