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
        "Model " ~ model.name 
        ~ "has models which depend on it. Be sure to run and test these, too!:\n- " 
        ~ for_models | join('\n- ')
    %}

    {#- Only check this at runtime -#}
    {%- if execute %}

        {#- Check if the models in the list are in the selected resources
         #  If any of them aren't, raise an exception.
         #}
        {%- for id in model_ids %}
            {%- if id not in selected_resources %}
                {{ exceptions.warn(error_message) }}
            {%- endif %}
        {%- endfor %}
    {%- endif %}
    select 1
{% endmacro %}