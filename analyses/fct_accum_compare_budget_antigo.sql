with int_fact_sales as(
    select
        product_id,
        substring(date_key,1,6) as month,
        sum(quantity_sold) as quantity_sold
    from {{ ref('fact_sales_orders_details') }}
    group by 1,2
),
stg_budget as (
    select
        product_id,
        to_char(month, 'YYYYMM') AS month_budget,
        target_quantity
    from {{ ref('stg_budget') }}
),

join_tables as(
    select
        stg_budget.product_id as product_id,    
        stg_budget.month_budget as month,
        stg_budget.target_quantity as target_quantity,
        int_fact_sales.quantity_sold as quantity_sold,
        case when int_fact_sales.quantity_sold >= stg_budget.target_quantity then 'sales_goal_achieve'
             else 'off_target' end as flag_goal_target

    from int_fact_sales
    full join stg_budget on stg_budget.product_id =   int_fact_sales.product_id
    order by 4 asc
)

select * from join_tables