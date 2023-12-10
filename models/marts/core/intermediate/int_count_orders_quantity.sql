{{
  config(
    materialized='view'
  )
}}


-- this intermediate model was made in order to calculate, for example, 
        -- the weighted cost of shipping_cost per line of product in a order, 
    
-- this cte counts the total number of products on each order_id



with int_count_orders_quantity as( 

    select
        order_id,
        case when sum(quantity_sold) <=0 then 1 
        else sum(quantity_sold) end as total_quantity_sold
    from {{ ref('stg_order_items') }}
    group by 1
    order by 1
)
select * from int_count_orders_quantity