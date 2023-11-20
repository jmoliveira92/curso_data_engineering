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
        coalesce(promo_discount, 0) as promo_discount,
        coalesce(promo_status, 'no_promo') as promo_status,
        date_load
    from distinct_promo_orders
    full outer join stg_promos on stg_promos.promo_id = distinct_promo_orders.promo_orders
)

select * from dim_promos