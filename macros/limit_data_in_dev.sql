# macro to limit data in dev environment for my bigger stg models

{% macro limit_data_in_dev(column_name) %}
{% if target.name == 'dev' %}
where {{ column_name }} >= '{{ var("dev_start_date") }}'::date
{% endif %}
{% endmacro %}