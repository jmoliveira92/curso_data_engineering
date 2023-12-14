with fact_orders as(
    select * from {{ ref('fact_orders') }}
),

resume as(
    select
        order_id,
        sum(shipping_line_cost_usd) as aa
    from fact_orders
    group by 1

)

select avg(aa) from resume
