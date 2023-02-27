{% macro snapshot_delete_old_records() %}
    {%- do log('---------------> Deleting records from snapshot older than 4 weeks', info=true) -%}
    delete from {{ this }} where dbt_valid_to <= dateadd(week, -4, date_trunc(week, current_date))
{% endmacro %}