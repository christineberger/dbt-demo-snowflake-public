{%- macro ensure_models_are_selected(for_models=[]) %}
    {#- We are assembling the unique_ids for the names passed in
     # because the selected_resources values select the unique_ids
     # of models and not the model names.
     #}
    {%- set model_ids = [] %}
    {%- for model_name in for_models %}
        {{ model_ids.append('model.' ~ project_name ~ '.' ~ model_name) }}
    {%- endfor %}

    {#- Assemble the error message that is shown when someone doesn't select the 
     #  required models in for_models.
     #}

    {%- set error_message = 
        "\nWhen running the model " ~ model.name 
        ~ " you need to ensure the following models are included in the selection:\n- " 
        ~ for_models | join('\n- ')
    %}

    {#- Check if the models in the list are in the selected resources
     #  If any of them aren't, raise an exception.
     #}
    {% do log('-----> SELECTED RESOURCES 1: ' ~ selected_resources, info=true) %}

    {% if execute %}
        {% do log('-----> SELECTED RESOURCES 2: ' ~ selected_resources, info=true) %}
        {%- for id in model_ids %}
            {%- if id not in selected_resources %}
                {{ exceptions.raise_compiler_error(error_message) }}
            {%- endif %}
        {%- endfor %}
    {% endif %}
{% endmacro %}