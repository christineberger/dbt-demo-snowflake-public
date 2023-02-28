{{ config(
    materialized='incremental',
    enabled=var('transfer_job_history_to_snowflake')
) }}

with

source as (
    select * from {{ ref('base_snowflake__query_history') }}
    where dbt_metadata['app']::string = 'dbt'
    and query_type not in ('ALTER SESSION', 'SHOW')

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
        query_text_no_comments,
        _dbt_json_comment_meta,
        dbt_metadata
    from source
)

select * from transformed        
order by start_time