with orders as(

    select * 
    from {{ ref('stg_orders') }}
),

dim_orders as(
    
    select
        order_id,
        cast(created_at as date) as order_date, 
        cast(created_at as time) as order_time,
        user_id,
        address_id
    from orders

)


select *  from dim_orders
