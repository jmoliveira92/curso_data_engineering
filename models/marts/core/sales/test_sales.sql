with int_fact_sales as(
    select
        product_id,
        date_trunc('month', created_at_utc) as month,
        sum(quantity_sold) as quantity_sold,
        created_at_utc

    from {{ ref('int_orders') }}
    group by 1,2
),
stg_budget as (
    select
        product_id,
        date_trunc('month', month_budget) as month_budget,
        target_quantity

    from {{ ref('stg_budget') }}
),

join_tables as(
    select
        c.date_key,
        b.product_id as product_id,    
        b.month_budget as month_budget,
        b.target_quantity as target_quantity,
        a.quantity_sold as quantity_sold,
        case when a.quantity_sold >= b.target_quantity then 1
             else 0 end as flag_goal

    from int_fact_sales a
    full join stg_budget b on b.product_id =   b.product_id
    order by 1 asc
)

select * from join_tables