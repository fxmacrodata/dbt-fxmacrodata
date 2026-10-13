select *
from {{ ref('stg_fxmacrodata') }}
where announcement_datetime is not null
