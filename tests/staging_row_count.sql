select 1 as mismatch
where (select count(*) from {{ source('fxmacrodata', 'records') }})
   <> (select count(*) from {{ ref('stg_fxmacrodata') }})
