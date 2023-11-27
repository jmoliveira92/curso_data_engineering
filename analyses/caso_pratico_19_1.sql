/*

## 19.1 Caso de Uso para el equipo de Producto

El equipo de producto necesita conocer para cada sesión:

- Todo lo referente al usuario de la sesión
- Inicio y fin de la misma
- Tiempo de duración de la sesión (minutos)
- Número de páginas vistas
- Número de eventos relacionados con add_to_cart, checkout y package_shipped.

LINKS UTILES:
 - Date_Trunc: https://docs.getdbt.com/sql-reference/date-trunc
 - Date_Part: https://docs.getdbt.com/sql-reference/datepart


OTHER METRICS
1. User Engagement Metrics:
        - Events per Session
        - Events over Time
2. Conversion Funnel:
        - Conversion Rate from 'page_view' to 'add_to_cart', 'checkout', 'package_shipped'
        - Conversion Rate from 'add_to_cart' to 'checkout', 'package_shipped'
3. Product Insights:
        - Most Viewed Products
        - Products with High Add-to-Cart Rate
4. Time Analysis:
        - Busiest Days/Hours
        - Day-wise 'add_to_cart' and 'checkout' Trends
5. User Journey:
        - Common Paths
6. Session Analysis
        - Average Session Duration
7. Session-based Metrics
        - Ranking Sessions by Activity
        - Identify First and Last Event in a Session
8. Time Lag Analysis:
        - Time Gap between Events within a Session
9. Sequential Analysis
        - Identify Next Event Type in Sequence
10. User Engagement Trends:
        - Calculate Rolling Average of Events (7 days)
11. Conversion Funnel Analysis:
        - Calculate Cumulative Conversion Rate

*/

with fact_events as (
    select * from {{ ref('fact_events') }}
),

dim_customers as(
    select * from {{ ref('dim_customers') }}
),

event_type as(
    select
        session_id,
        user_sk,
        sum(case when event_type = 'checkout' then 1 else 0 end) as checkout,
        sum(case when event_type = 'package_shipped' then 1 else 0 end) as package_shipped,
        sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_cart,
        sum(case when event_type = 'page_view' then 1 else 0 end) as page_view
    from fact_events
    group by 1,2
),

--select * from event_type

session_lenght as(
    select
        user_sk,
        first_event_time_utc,
        last_event_time_utc,
        {{ dbt.datediff("first_event_time_utc", "last_event_time_utc", "minute") }} as session_lenght_minutes
    from (
            select
                user_sk,
                min(created_at_utc) as first_event_time_utc,
                max(created_at_utc) as last_event_time_utc
            from fact_events
            group by 1)
),

--select * from session_lenght

exercicio as(
    select
        a.session_id,
        b.user_id,
        b.full_name,
        b.email,
        c.first_event_time_utc,
        c.last_event_time_utc,
        c.session_lenght_minutes,
        d.page_view,
        d.add_to_cart,
        d.checkout,
        d.package_shipped   
        
    from fact_events a

    left join dim_customers b on b.user_sk = a.user_sk
    left join session_lenght c on c.user_sk = a.user_sk
    left join event_type d on d.session_id = a.session_id
    group by 1,2,3,4,5,6,7,8,9,10,11
    order by 8 desc
),

--select * from exercicio


-- testing Window functions

window_function as (
    select
        event_id,
        session_id,
        user_sk,
        event_type,
        created_at_utc,
        row_number() over(partition by session_id, user_sk order by created_at_utc desc) as event_order
    from fact_events

),

--select * from window_function

-- 1. User Engagement Metrics:
        
    -- AVG events per session
    -- RESP: 6,15 
events_per_session as(

        select round(AVG(events_per_session),2) as avg_events_per_session
        from (
            select session_id,
            COUNT(*) as events_per_session 
            from fact_events 
            group by session_id)
),

--select * from events_per_session

    -- Events over Time
events_over_time as(
    SELECT 
        DATE_TRUNC('hour', created_at_utc) AS hour_date, 
        COUNT(*) AS events_count
    FROM fact_events
    GROUP BY hour_date
    ORDER BY hour_date
),



--select * from events_over_time

-- 2. Conversion Funnel:

    -- Conversion Rate from 'page_view' to 'add_to_cart', 'checkout', 'package_shipped'

conversion_rate_page_view as(
    SELECT
        COUNT(CASE WHEN event_type = 'page_view' THEN 1 END) AS page_views,
        COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END) AS add_to_cart,
        COUNT(CASE WHEN event_type = 'checkout' THEN 1 END) AS checkout,
        COUNT(CASE WHEN event_type = 'package_shipped' THEN 1 END) AS package_shipped
    FROM fact_events
),

--select * from conversion_rate_page_view

-- 3. Product Insights:

    -- Most Viewed Products
most_view_products as(
    SELECT top 5
        product_sk, 
        COUNT(*) AS views
    FROM fact_events
    WHERE event_type = 'page_view' AND product_sk IS NOT NULL
    GROUP BY product_sk
    ORDER BY views DESC
),


--select * from most_view_products

    --Products with High Add-to-Cart Rate

products_high_cart_rate as(
    SELECT top 5
        product_sk, 
        COUNT(*) AS add_to_cart_count
    FROM fact_events
    WHERE event_type = 'add_to_cart' AND product_sk IS NOT NULL
    GROUP BY product_sk
    ORDER BY add_to_cart_count DESC
),


--select * from products_high_cart_rate

-- 4. TIME ANALYSIS ---
    -- Busiest Hours:

busiest_hours as (
    SELECT top 5
        DATE_TRUNC('hour', created_at_utc) AS busiest_hours,
        COUNT(*) AS events_count
    FROM fact_events
    GROUP BY busiest_hours
    ORDER BY events_count DESC
),

--select * from busiest_hours

-- 5. User Journey
    -- Common Paths:
common_paths as (
    SELECT
        page_url,
        LEAD(page_url) OVER (ORDER BY created_at_utc) AS next_page
    FROM fact_events
    WHERE event_type = 'page_view'
    ORDER BY created_at_utc
),


--select * from common_paths


-- 6. Session Analysis
    -- Average Session Duration:

avg_session_duration as(
    SELECT AVG(session_duration) AS avg_session_duration
FROM (
  SELECT
    session_id,
    datediff('hour',MIN(created_at_utc),MAX(created_at_utc)) AS session_duration
  FROM fact_events
  GROUP BY session_id
    ) sessions
),


--select * from avg_session_duration

-- WINDOW FUNCTIONS --


-- 7. Session-based Metrics  --

    --Ranking Sessions by Activity
rank_sessions as(
    SELECT
        session_id,
        COUNT(*) AS events_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS session_rank
    FROM fact_events
    GROUP BY session_id
    ORDER BY events_count DESC
),


--select * from rank_sessions

    -- Identify First and Last Event in a Session
first_last_events as(
    SELECT
        session_id,
        event_id,
        ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created_at_utc) AS event_order,
        FIRST_VALUE(event_id) OVER (PARTITION BY session_id ORDER BY created_at_utc) AS first_event_id,
        LAST_VALUE(event_id) OVER (PARTITION BY session_id ORDER BY created_at_utc) AS last_event_id
    FROM fact_events
),


--select * from first_last_events

-- 8. Time Lag Analysis (Time Gap between Events within a Session):

time_lag as(
    SELECT
        session_id,
        event_id,
        created_at_utc,
        LAG(created_at_utc) OVER (PARTITION BY session_id ORDER BY created_at_utc) AS prev_event_time,
        datediff('minute',LAG(created_at_utc) OVER (PARTITION BY session_id ORDER BY created_at_utc),created_at_utc) AS time_gap_min
    from fact_events
    ORDER BY session_id, created_at_utc
),

--select * from time_lag


-- 9.Sequential Analysis:

    -- Identify Next Event Type in Sequence

next_event_sequence as(

    SELECT
  session_id,
  event_id,
  event_type,
  LEAD(event_type) OVER (PARTITION BY session_id ORDER BY created_at_utc) AS next_event_type
FROM fact_events
ORDER BY session_id, created_at_utc
),

--select * from next_event_sequence

-- 10. User Engagement Trends:

    -- Calculate Rolling Average of Event

rolling_avg_event as(
SELECT
  created_at_utc,
  event_type,
  COUNT(*) OVER (ORDER BY created_at_utc) AS rolling_count
FROM fact_events
ORDER BY created_at_utc
),
--select * from rolling_avg_event


-- 11. Conversion Funnel Analysis

    -- Calculate Cumulative Conversion Rate
    
cum_conversion_rate as(
    SELECT
  created_at_utc,
  event_type,
  COUNT(CASE WHEN event_type = 'page_view' THEN 1 END) OVER (ORDER BY created_at_utc) AS page_views,
  COUNT(CASE WHEN event_type = 'add_to_cart' THEN 1 END) OVER (ORDER BY created_at_utc) AS add_to_cart,
  COUNT(CASE WHEN event_type = 'checkout' THEN 1 END) OVER (ORDER BY created_at_utc) AS checkout,
  COUNT(CASE WHEN event_type = 'package_shipped' THEN 1 END) OVER (ORDER BY created_at_utc) AS package_shipped
FROM fact_events
ORDER BY created_at_utc
),
-- select * from cum_conversion_rate
