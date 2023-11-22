with dim_promos as (
    select * from {{ ref('dim_promos') }}
),

dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),

--preciso fazer aqui uma tabela intermedia com as colunas de 
-- "dim_sales_orders": 'order_id' + "dim_promos": "discount"
-- fazendo join ataves da coluna "promo__sk"

int_discount as(
    select
        {{dbt_utils.generate_surrogate_key(['dim_sales_orders.order_id'])}} as order_sk,
        dim_sales_orders.order_id,
        case when dim_promos.promo_discount_percent is null then 0
             else cast(dim_promos.promo_discount_percent/100 as decimal(24,2)) end as discount
    from dim_sales_orders
    left join {{ ref('dim_promos') }} on dim_promos.promo_sk = dim_sales_orders.promo_sk

)

select * from int_discount