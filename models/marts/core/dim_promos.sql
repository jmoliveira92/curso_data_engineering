with stg_promos as (
    select * from {{ ref('stg_promos') }}
),
no_promo_row as(
    select * from (values('no_promo','no_promo',0,0,'inactive'))
),

dim_promos as(
    select
        {{dbt_utils.generate_surrogate_key(['promo_id'])}} as promo_sk,
        promo_id,
        decode(promo_discount,null,0,promo_discount) as promo_discount_percent,
        decode(promo_discount,null,0,promo_discount/100) as discount_unit,
        decode(promo_status,'','inactive',null,'inactive',promo_status) as promo_status

    from stg_promos
    )

select * from dim_promos
union all
select * from no_promo_row