{% macro fxmacrodata_records(operation=none) %}
select *
from {{ ref('stg_fxmacrodata') }}
{% if operation is not none %}
where operation = {{ dbt.string_literal(operation) }}
{% endif %}
{% endmacro %}
