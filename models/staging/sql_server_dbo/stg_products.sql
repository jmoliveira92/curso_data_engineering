with products as(

    select * 
    from {{ source('src_sql_server_dbo', 'products') }}
),
no_product_row as(
select * from (values ('no_product','no_product',0,1,current_timestamp()))
),

stg_products as(
select
    product_id::varchar(50) as product_id,
    name::varchar(50) as product_name,
    price::decimal(24,2) as unit_price_usd,
    inventory::int as inventory,
    _FIVETRAN_SYNCED as date_load
from products
)

select *  from stg_products
union all 
select * from no_product_row

