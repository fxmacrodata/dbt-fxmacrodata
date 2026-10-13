select staged.record_id
from {{ ref('stg_fxmacrodata') }} staged
join {{ source('fxmacrodata', 'records') }} original
  on staged.record_id = original.record_id
where original.announcement_datetime is null
  and staged.announcement_datetime is not null
