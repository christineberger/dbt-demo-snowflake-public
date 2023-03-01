{{ config(
    materialized='incremental',
    enabled=var('transfer_job_history_to_snowflake') 
) }}

with

source as (
    select * from {{ ref('base_snowflake__query_history') }}
    
    -- This helps for filtering only to items sent from dbt
    -- and that this is only captured for items coming from a run.
    where dbt_metadata['app']::string = 'dbt'
    and dbt_metadata['dbt_cloud_run_id'] is not null

    -- Using end_time ensures it captures items which haven't been completed
    -- Filtering to the current user ensures that we're only adding history items
    -- that are newly added from the user that was running the models
    {%- if is_incremental() %}
    and end_time > (select max(end_time) from {{ this }} where lower(user_name) = {{ target.user | lower }})
    {%- endif %}
),

extract_dbt_metadata as (
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
    from source
),

enrich as (
    select
        'https://cloud.getdbt.com/deploy/' || dbt_cloud_account_id || '/projects/' || dbt_cloud_project_id || '/runs/' || dbt_cloud_run_id as dbt_cloud_job_url,
        any_value(dbt_cloud_project_id) as dbt_cloud_project_id,
        any_value(dbt_cloud_job_id) as dbt_cloud_job_id,
        any_value(dbt_cloud_run_id) as dbt_cloud_run_id,
        any_value(dbt_cloud_run_reason) as dbt_cloud_run_reason,
        listagg(
           coalesce(dbt_job_node_resource_type, 'error_code ' || error_code) || ', '
           || coalesce(dbt_job_node_name, 'Query ID ' || query_id) || ':\n' 
           || error_message, ',\n\n'
        ) as error_messages
    from enrich
    group by 1
)

select * from transformed        
order by start_time

with

dbt_query_history as (
    select * from "DEVELOPMENT"."DBT_CBERGER__PROD_DEMO_JOB_LOGGING__QUERY_LOGS"."STG_SNOWFLAKE__QUERY_HISTORY"
    where dbt_metadata['dbt_cloud_run_id'] is not null
),

enrich as (
    select
        dbt_metadata['dbt_cloud_job_id']::string as dbt_cloud_job_id,
        dbt_metadata['dbt_cloud_project_id']::string as dbt_cloud_project_id,
        dbt_metadata['dbt_cloud_run_id']::string as dbt_cloud_run_id,
        dbt_metadata['dbt_cloud_run_reason']::string as dbt_cloud_run_reason,
        dbt_metadata['node_name']::string as dbt_job_node_name,
        dbt_metadata['node_resource_type']::string as dbt_job_node_resource_type,
        *
    from dbt_query_history
),

final as (
    select
        'https://cloud.getdbt.com/deploy/' || dbt_cloud_job_id || '/projects/' || dbt_cloud_project_id || '/runs/' || dbt_cloud_run_id as dbt_cloud_job_url,
        any_value(dbt_cloud_project_id) as dbt_cloud_project_id,
        any_value(dbt_cloud_job_id) as dbt_cloud_job_id,
        any_value(dbt_cloud_run_id) as dbt_cloud_run_id,
        any_value(dbt_cloud_run_reason) as dbt_cloud_run_reason,
        listagg(
           coalesce(dbt_job_node_resource_type, 'error_code ' || error_code) || ', '
           || coalesce(dbt_job_node_name, 'Query ID ' || query_id) || ':\n' 
           || error_message, ',\n\n'
        ) as error_messages
    from enrich
    group by 1
    
)

select * from final;