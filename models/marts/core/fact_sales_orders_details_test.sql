
with int_orders as(    
    select * from {{ ref('int_orders') }}
),

dim_date as (
    select* from {{ ref('dim_date') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

fact_sales_orders_details as(

    select
        b.date_key,
        a.order_id,
        f.product_id,
        --a.status,
        a.quantity_sold,
        f.price,
        a.created_at_utc,
        a.created_at_date

    from int_orders a

    left join dim_date b on b.date_day = a.created_at_date
    left join dim_products f on f.product_id = a.product_id 
    --AND a.created_at_date between f.begin_eff_date and f.end_eff_date

-- left join snapshot_product c on c.product_id = a.product_id 
-- AND a.created_at_date between c.dbt_valid_from and c.dbt_valid_to

    where a.product_id IN ('37e0062f-bd15-4c3e-b272-558a86d90598')

)

select count(distinct order_id) from fact_sales_orders_details order by created_at_utc desc

/*
37e0062f-bd15-4c3e-b272-558a86d90598
615695d3-8ffd-4850-bcf7-944cf6d3685b
579f4cd0-1f45-49d2-af55-9ab2b72c3b35
e18f33a6-b89a-4fbc-82ad-ccba5bb261cc
e2e78dfc-f25c-4fec-a002-8e280d61a2f2
*/