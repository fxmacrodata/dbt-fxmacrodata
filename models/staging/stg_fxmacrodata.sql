select
{% for column in fxmacrodata.fxmacrodata_columns() %}
    cast({{ adapter.quote(column) }} as {% if column == 'value' %}{{ dbt.type_float() }}{% else %}{{ dbt.type_string() }}{% endif %}) as {{ adapter.quote(column) }}{% if not loop.last %},{% endif %}
{% endfor %}
from {{ source('fxmacrodata', 'records') }}
