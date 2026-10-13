select staged.record_id
from {{ ref('stg_fxmacrodata') }} staged
left join {{ source('fxmacrodata', 'records') }} original
  on staged.record_id = original.record_id
 and staged.record_json = original.record_json
 and staged.response_json = original.response_json
where original.record_id is null
