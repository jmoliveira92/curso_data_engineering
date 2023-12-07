with promos as (

    select *
    from {{ source('src_sql_server_dbo', 'promos') }}
),

stg_promos as (
select
    promo_id::varchar(50) as promo_id,
    decode(discount,null,0,discount)::float as promo_discount_percent,
    decode(status,'','inactive',null,'inactive',status)::varchar(50) as promo_status,
    coalesce(_fivetran_deleted, false)::boolean as row_deleted,
    _fivetran_synced as date_load
from promos
),
no_promo_row as(
    select * from (values('no_promo',0,'inactive','false',current_timestamp()))
)

select * from stg_promos
union all
select * from no_promo_row