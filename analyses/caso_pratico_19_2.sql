/* ## 19.2. Caso de Uso para el equipo de Marketing

El equipo de producto necesita conocer para cada usuario todo lo referente a las compras que ha realizado. 
Para ello nos solicitan que indiquemos:

- Toda la información disponible del usuario
- Número de pedidos totales que ha realizado
- Total gastado
- Total de gastos de envío
- Descuento total
- Total de productos que ha comprado
- Total de productos diferentes que ha comprado.

*/
with dim_customers as (
    select * from {{ ref('dim_customers') }}
),
dim_addresses as (
    select * from {{ ref('dim_addresses') }}
),
dim_sales_orders as (
    select * from {{ ref('dim_sales_orders') }}
),
fact_sales_orders_details as (
    select * from {{ ref('fact_sales_orders_details') }}
),

agg_fact as(
    select
        user_sk,
        count(order_sk) as total_number_orders,
        sum(gross_sales_usd) as total_sales_usd,
        sum(shipping_cost_usd) as total_shipping_cost_usd,
        sum(discount_amount_usd) as total_discount_usd,
        count(product_sk) as total_quantity_products,
        count(distinct product_sk) as total_different_products
    from fact_sales_orders_details
    group by 1
    order by 3 desc
),

exercicio as (
    select
        a.user_sk,
        a.full_name,
        a.email,
        a.phone_number,
        a.created_at_utc,
        a.updated_at_utc,
        b.address,
        b.zipcode,
        b.state,
        b.country,
        decode(c.total_number_orders,null,0,c.total_number_orders) as total_number_orders,
        decode(c.total_sales_usd,null,0,total_sales_usd) as total_sales_usd,
        decode(c.total_shipping_cost_usd,null,0,c.total_shipping_cost_usd) as total_shipping_cost_usd,
        decode(c.total_discount_usd,null,0,c.total_discount_usd) as total_discount_usd,
        decode(c.total_quantity_products,null,0,c.total_quantity_products) as total_quantity_products,
        decode(c.total_different_products,null,0,c.total_different_products) as total_different_products

    from dim_customers a
    left join dim_addresses b on b.address_sk = a.address_sk
    full join agg_fact c on c.user_sk = a.user_sk
    --left join dim_sales_orders y on y.user_sk = a.user_sk
    order by 12 desc
),

--select * from exercicio


-- 1. Product Performance

    --Identify top-selling products by quantity_sold or gross_sales_usd.

top_selling_prod as(
    SELECT
    product_sk,
        SUM(quantity_sold) AS total_quantity_sold,
        SUM(gross_sales_usd) AS total_gross_sales,
        (SUM(gross_sales_usd)/SUM(quantity_sold)) as price_per_unit
    FROM
    fact_sales_orders_details
    GROUP BY
    product_sk
    ORDER BY
    total_quantity_sold DESC, total_gross_sales DESC
),
 
  --  select * from top_selling_prod

    --Analyze the performance of products with the highest and lowest unit prices.

high_low_prices as(
    SELECT
        product_sk,
        MAX(unit_price_usd) AS highest_unit_price,
        MIN(unit_price_usd) AS lowest_unit_price
    FROM fact_sales_orders_details
    GROUP BY product_sk
),

--select * from high_low_prices

-- 2. Discount Analysis

    -- Examine the distribution of discounts.

distr_discount as(
    SELECT
        discount_usd,
        COUNT(*) AS discount_count
    FROM fact_sales_orders_details
    GROUP BY discount_usd
    ORDER BY discount_usd
),
--select * from distr_discount

    -- Calculate the average discount per product and overall.

avg_discount_product as(
    SELECT
        product_sk,
        round(AVG(discount_usd),3) AS avg_discount_per_product
    FROM fact_sales_orders_details
    GROUP BY product_sk
),
--select * from avg_discount_product

avg_discount_overall as(
    SELECT
	    round(AVG(discount_usd),3) AS avg_discount_overall
    FROM fact_sales_orders_details
),
--select * from avg_discount_overall


-- 3. Sales Revenue Analysis

    -- Understand the overall revenue trend over time.

revenue_trend as(
    SELECT
        DATE_TRUNC('hour', created_at_utc) AS hours,
        SUM(gross_sales_usd) AS total_gross_sales
    FROM fact_sales_orders_details
    GROUP BY 1
    ORDER BY 1
),
--select * from revenue_trend

    -- Compare gross sales, net sales, and discount amounts.

compare_amounts as(
    SELECT
        product_sk,
        SUM(gross_sales_usd) AS total_gross_sales,
        SUM(net_sales_amout) AS total_net_sales,
        SUM(discount_amount_usd) AS total_discount
    FROM fact_sales_orders_details
    GROUP BY product_sk
),
--select * from compare_amounts

    -- Identify any seasonality or trends in sales.


trend_sales as(
    SELECT
        EXTRACT(hour FROM created_at_utc) AS hours,
        round(AVG(gross_sales_usd),2) AS avg_hourly_sales
    FROM fact_sales_orders_details
    GROUP BY hours
    ORDER BY hours
),
--select * from trend_sales

--4. Shipping Cost Impact

    --Analyze the impact of shipping costs on net sales.

ship_cost_impact as(
    SELECT
        product_sk,
        round(AVG(shipping_cost_usd),2) AS avg_shipping_cost
    FROM fact_sales_orders_details
    GROUP BY product_sk
    ORDER BY avg_shipping_cost DESC
),
--select * from ship_cost_impact


    --Identify products or orders with disproportionately high shipping costs.

high_prod_ship_costs as(
    SELECT
        product_sk,
        round(AVG(shipping_cost_usd),2) AS avg_shipping_cost,
        round(AVG(net_sales_amout),2) AS avg_net_sales
    FROM fact_sales_orders_details
    GROUP BY product_sk
    ORDER BY avg_shipping_cost DESC
),
--select * from high_prod_ship_costs


-- 5. Delivery Time Analysis:

    --Calculate average days to deliver for all orders.

avg_days_deliver as(
    SELECT
        AVG(days_to_deliver) AS avg_days_to_deliver
    FROM fact_sales_orders_details
),
--select * from avg_days_deliver

    -- Identify orders with unusually short or long delivery times.

short_long_deliver_time as(
    SELECT
        order_sk,
        days_to_deliver
    FROM fact_sales_orders_details
    WHERE days_to_deliver < (SELECT AVG(days_to_deliver) - 1 * STDDEV(days_to_deliver) FROM fact_sales_orders_details)
    OR days_to_deliver > (SELECT AVG(days_to_deliver) + 1 * STDDEV(days_to_deliver) FROM fact_sales_orders_details)
    order by 2 desc
    ),
--select * from short_long_deliver_time


    -- Investigate the relationship between shipping cost and delivery time.

ship_deliver_relation as(
    SELECT
        shipping_cost_usd,
        AVG(days_to_deliver) AS avg_delivery_time
    FROM fact_sales_orders_details
    GROUP BY shipping_cost_usd
    order by 1 desc
),
--select * from ship_deliver_relation

-- 6. Delivery Precision:

    -- Evaluate the accuracy of estimated delivery dates

accuracy_est_deliver as(
    SELECT
        AVG(CASE WHEN estimated_delivery_at_utc = delivered_at_utc THEN 1 ELSE 0 END)*100 AS accuracy_percentage
    FROM fact_sales_orders_details
)
select * from accuracy_est_deliver
    -- Compare estimated and actual delivery dates

    -- Identify patterns where precision tends to be higher or lower

-- 7. Order Analysis:

    -- Analyze the distribution of order quantities.

    --Investigate the relationship between order quantity and discount.

-- 8. Correlation Analysis:

    -- Explore correlations between different metrics (e.g., gross sales, discount, days to deliver).

    -- Identify factors that may influence sales and delivery times.

-- 9. Customer Segmentation:

    -- Segment customers based on their purchasing behavior.

    -- Analyze whether certain customer segments tend to receive higher discounts or have longer delivery times.

-- 10. Profitability Analysis:

    -- Calculate the overall profitability of each sale.

    -- Identify products or orders with the highest and lowest profitability.

