with stg_order_items as(
    select * from {{ ref('stg_order_items') }}
),

stg_products as(
    select * from {{ ref('stg_products') }}
),

fact_inventory as(
    select
        a.product_id,
        b.inventory as inventory_initial_balance,
        sum(a.quantity_sold) as inventory_sold
    from stg_order_items a
    full outer join stg_products b on b.product_id = a.product_id
    group by 1,2
    order by 3 desc
),

flag as(
    select
        product_id,
        case when inventory_sold > inventory_initial_balance then 'Alert!'
             else 'OK' end as selled_more_than_inventory,
        current_timestamp() as created_at_utc
    from fact_inventory
)

select 
    a.product_id,
    a.inventory_initial_balance,
    a.inventory_sold,
    b.selled_more_than_inventory,
    b.created_at_utc
from fact_inventory a
join flag b on b.product_id = a.product_id
order by 4 asc, 3 desc