with stg_products as(
    select * from {{ ref('stg_products') }}
),
stg_product_features as(
    select * from {{ ref('stg_product_features') }}
),

dim_products as (

    select
        {{dbt_utils.generate_surrogate_key(['a.product_id','a.product_name','a.unit_price_usd'])}} as product_sk,
        a.product_id,
        a.product_name,
        a.unit_price_usd,
        decode(product_cost_usd,null,0,round(product_cost_usd,2)) as product_cost_usd,
        a.inventory
    from stg_products a
    left join stg_product_features b on b.product_id=a.product_id
)

select * from dim_products