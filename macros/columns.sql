{% macro fxmacrodata_columns() %}
  {{ return(['operation', 'source_url', 'record_id', 'currency', 'indicator',
             'date', 'announcement_datetime', 'value', 'value_text',
             'record_json', 'response_json']) }}
{% endmacro %}
