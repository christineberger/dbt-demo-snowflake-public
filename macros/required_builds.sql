{%- macro required_builds(for_models=[]) %}
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
        "\n`" ~ model.name ~ "`"
        ~ " has been configured to require other models on selection when executing.\n"
        ~ " You need to ensure the following models will run within your selection:\n\t- " 
        ~ for_models | join('\n- ')
    %}

    {#- Check if the models in the list are in the selected resources
     #  If any of them aren't, raise an exception.
     #}
    {% if execute %}
        {%- for id in model_ids %}
            {%- if id not in selected_resources %}
                {{ exceptions.raise_compiler_error(error_message) }}
            {%- endif %}
        {%- endfor %}
    {% endif %}

    {{ return('select 1 as hack_to_return_sql_on_hook') }}

{% endmacro %}