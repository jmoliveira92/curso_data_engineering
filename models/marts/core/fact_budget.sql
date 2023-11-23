with stg_budget as(

    select * from {{ ref('stg_budget') }}
),

dim_products as (

    select
        product_sk,
        product_id
    from {{ ref('dim_products') }}
),
dim_date as (
    select
        date_key,
        date_day
    from {{ ref('dim_date') }}
),
fact_budget as(
    
    select
        a.budget_sk,
        b.product_sk,
        a.target_quantity,
        c.date_key

    from stg_budget a
    left join dim_products b on b.product_id = a.product_id
    left join dim_date c on c.date_day = a.date_day
)

select * from fact_budget