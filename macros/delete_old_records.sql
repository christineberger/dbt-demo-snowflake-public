{% macro get_is_updated(motdel) %}
    {% if execute %}
        {% do log('RESULTS ------>' ~ this, info=true) %}
    {% endif %}
{% endmacro %}