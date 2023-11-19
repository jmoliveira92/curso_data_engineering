with stg_products as(
    select * from {{ ref('stg_products') }}
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