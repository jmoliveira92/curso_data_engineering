with promos as (

    select *
    from {{ source('src_sql_server_dbo', 'promos') }}
),

stg_promos as (
select
    promo_id::varchar(50) as promo_id,
    discount::float as promo_discount,
    status::varchar(50) as promo_status,
    coalesce(_fivetran_deleted, false)::boolean as row_deleted,
    _fivetran_synced as date_load
from promos
)

select * from stg_promos
