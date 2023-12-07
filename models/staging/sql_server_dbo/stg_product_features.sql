
with stg_product_cost as(
    select
        product_id::varchar as product_id,
        product_cost::decimal(12,2) as product_cost_usd,
        product_weight::decimal(12,2) as product_weight_kg
    from {{ ref('product_features') }}
)
select * from stg_product_cost