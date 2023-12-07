-- macro that sums the total of units sold

{% macro sum_quantity_sold() %}
    SELECT
        SUM(quantity_sold)
    FROM {{ ref('stg_order_items') }}
{% endmacro %}
