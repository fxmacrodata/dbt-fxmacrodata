select *
from {{ ref('stg_fxmacrodata') }}
where value is not null
