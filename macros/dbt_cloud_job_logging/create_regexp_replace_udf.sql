{% macro create_regexp_replace_udf(relation) %}

create or replace function {{ relation.database }}.{{ relation.schema }}.job_logging_regexp_replace(subject text, pattern text, replacement text)
returns string
language javascript
comment = 'Created by dbt-snowflake-monitoring dbt package.'
as
$$
    const p = SUBJECT;
    let regex = new RegExp(PATTERN, 'g')
    return p.replace(regex, REPLACEMENT);
$$

{% endmacro %}