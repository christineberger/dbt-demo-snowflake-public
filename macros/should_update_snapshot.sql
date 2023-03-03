{% macro should_update_snapshot() %}
        {% set table_exists = load_relation(this) is not none %}

        -- If the table exists in the warehouse
        {% if table_exists %}
            {% if execute %}
                {% set results = run_query('select date(max(dbt_valid_from)) = current_date from ' ~ this) %}
                {% set results_list = results.columns[0].values() %}
            {% else %}
                {% set results_list = [] %}
            {% endif %}

            -- True is returned if the max date in the current snapshot is from today, otherwise returns False
            {% set is_updated = results_list[0] %}

            -- If the most up to date data is from today, then the data has been updated already and the snapshot shouldn't run
            {% if is_updated | lower == 'true' %}
                {% set should_update = False %}
            -- Otherwise, we can assume the snapshot didn't run for today and the snapshot should be updated
            {% else %}
                {% set should_update = True %}
            {% endif %}
        -- If the table doesn't exist in the warehouse
        {% else %}
            {% set should_update = True %}
        {% endif %}

        {{ return(should_update) }}
{% endmacro %}