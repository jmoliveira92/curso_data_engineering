/* 19. Ejercicios prácticos

1. ¿Cuántos usuarios tenemos?

select 
    count(distinct user_id)-1 as number_of_users -- '-1' serves to do not take into account the "no_user"
from dim_users

2. En promedio, ¿cuánto tiempo tarda un pedido desde que se realiza hasta que se entrega?

select 
    round(avg(days_to_deliver),2) as avg_days_delivery
from fact_orders
--RESPOSTA: 3.83 days

3. ¿Cuántos usuarios han realizado una sola compra? ¿Dos compras? ¿Tres o más compras?
        #RESP.1: 26
        #RESP.2: 28
        #RESP.3: 34


- *Nota: debe considerar una compra como un solo pedido. En otras palabras, si un usuario realiza un pedido de 3 productos, se considera que ha realizado 1 compra.*
- En promedio, ¿Cuántas sesiones únicas tenemos por hora?
*/
with dim_users as (
    select * from {{ ref('dim_users') }}
),

fact_orders as(
    select * from {{ ref('fact_orders') }}
),

int_orders as (
    select * from {{ ref('int_orders') }}
),

fact_events as(
    select * from {{ ref('fact_events') }}
),

resp_1 as(
    select 
        count(distinct user_id)-1 as number_of_users -- '-1' serves to do not take into account the "no_user"
    from dim_users
),

resp_2 as(
    select 
    round(avg(days_to_deliver),2) as avg_days_delivery
from fact_orders
),

resp_3 as(

select
    number_of_purchases,
    count(number_of_purchases) as number_of_users
from(
        select
            user_id,
            count(distinct order_id) as number_of_purchases
        from int_orders
        group by 1
        having number_of_purchases = 1 OR number_of_purchases = 2 OR number_of_purchases = 3)
group by 1
order by 1
),

resp_4 as(

select
    date_part('hour', created_at_utc) as per_hour,
    count(distinct session_id) as number_of_sessions
from fact_events
group by 1
order by 1
),

resp_5 as(

    select
        date_trunc('hour',created_at_utc) as fecha,
        date_part('hour', created_at_utc) as per_hour,
        count(distinct session_id) as number_of_sessions
    from fact_events
    group by 1,2
    order by 1,2
)

select * from resp_5

