with stg_products as(
    select * from {{ ref('stg_products') }}
),
no_product_row as(
select * from (values ('no_product','no_product','no_product',0,0))
),

dim_products as (

    select
        {{dbt_utils.generate_surrogate_key(['product_id'])}} as product_sk,
        product_id,
        product_name,
        unit_price_usd,
        inventory
    from stg_products
    order by 3

)

select * from dim_products
union all
select * from no_product_row