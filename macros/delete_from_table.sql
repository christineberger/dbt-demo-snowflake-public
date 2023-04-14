{% macro delete_from_table(model, source_key=None) -%}
    {% if execute %}
        {# --------------------------------- VARIABLES ---------------------------#}
        {%- set source = source(model.sources[0][0], model.sources[0][1]) -%}
        {%- set target = model.relation_name -%}
        {%- set source_id = source_key if source_key is not none else model.config.get('unique_key') -%}
        {%- set target_id = model.config.get('unique_key') %}
        
        {# --------------------------------- PROCESS ------------------------------#}
        create or replace table deleted_records__{{ model.relation_name }} as 
            select {{ source_id }} as id from {{ source }}
            where is_deleted
        
        merge into {{ target }} as DBT_INTERNAL_DELETE_DEST
            using deleted_records__{{ model.relation_name }} as DBT_INTERNAL_DELETE_SOURCE
            on DBT_INTERNAL_DELETE_SOURCE.{{ source_id }} = DBT_INTERNAL_DELETE_DEST.{{ target_id }}
            when matched then delete
    {% endif %}
    {{ return('select 1 as success') }}
{% endmacro %}
