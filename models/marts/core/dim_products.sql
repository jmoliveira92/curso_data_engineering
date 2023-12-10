with stg_products as(
    select * from {{ ref('stg_products') }}
),
stg_product_features as(
    select * from {{ ref('stg_product_features') }}
),

dim_products as (

    select
        {{dbt_utils.generate_surrogate_key(['a.product_id','a.product_name'])}} as product_sk,
        a.product_id,
        a.product_name,
        a.msrp_price_usd,
        b.product_weight_lbs,
        a.updated_at
    from stg_products a
    left join stg_product_features b on b.product_id=a.product_id
)

select * from dim_products