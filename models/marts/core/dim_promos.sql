with stg_promos as (
    select * from {{ ref('stg_promos') }}
),

dim_promos as(
    select
        {{dbt_utils.generate_surrogate_key(['promo_id'])}} as promo_sk,
        promo_id,
        promo_discount,
        promo_status,
        date_load
    from stg_promos
)

select * from dim_promos