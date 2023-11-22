with stg_promos as (
    select * from {{ ref('stg_promos') }}
),
distinct_promo_orders as(
    select distinct 
        promo_id as promo_orders
    from {{ ref('stg_orders') }}
),
dim_promos as(
    select
        {{dbt_utils.generate_surrogate_key(['promo_id'])}} as promo_sk,
        promo_orders as promo_id,
        decode(promo_discount,null,0,promo_discount) as promo_discount_percent,
        decode(promo_status,'','inactive',null,'inactive',promo_status) as promo_status

    from distinct_promo_orders
    full outer join stg_promos on stg_promos.promo_id = distinct_promo_orders.promo_orders
)

select * from dim_promos