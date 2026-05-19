SELECT VERSION();
SHOW DATABASES;
CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

USE olist_ecommerce;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers_dataset
UNION ALL
SELECT 'orders',    COUNT(*) FROM orders_dataset
UNION ALL
SELECT 'items',     COUNT(*) FROM order_items_dataset;

USE olist_ecommerce;

SELECT
    COUNT(DISTINCT o.order_id)           AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price), 2)              AS total_revenue,
    ROUND(AVG(oi.price), 2)              AS avg_item_price,
    ROUND(SUM(oi.freight_value), 2)      AS total_freight
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
JOIN customers_dataset c   ON o.customer_id = c.customer_id;

SELECT
    order_status,
    COUNT(*)AS order_count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders_dataset), 1) AS percentage
FROM orders_dataset
GROUP BY order_status
ORDER BY order_count DESC;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)AS total_orders,
    ROUND(SUM(oi.price), 2)AS monthly_revenue
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)           AS total_orders,
    ROUND(SUM(oi.price), 2)              AS total_revenue,
    ROUND(AVG(oi.price), 2)              AS avg_order_value
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
JOIN customers_dataset c   ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    CASE
        WHEN DATEDIFF(order_delivered_customer_date,
             order_purchase_timestamp) <= 7  THEN 'Fast (1-7 days)'
        WHEN DATEDIFF(order_delivered_customer_date,
             order_purchase_timestamp) <= 14 THEN 'Normal (8-14 days)'
        WHEN DATEDIFF(order_delivered_customer_date,
             order_purchase_timestamp) <= 30 THEN 'Slow (15-30 days)'
        ELSE 'Very Slow (30+ days)'
    END                                  AS delivery_speed,
    COUNT(*)                             AS orders,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders_dataset
         WHERE order_status = 'delivered'
         AND order_delivered_customer_date IS NOT NULL), 1) AS pct
FROM orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_speed
ORDER BY orders DESC;

-- Q6. Running cumulative revenue by month
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders_dataset o
    JOIN order_items_dataset oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')
)
SELECT
    month, revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM monthly;

-- Q7. Late deliveries analysis
SELECT
    COUNT(*)                             AS total_delivered,
    SUM(CASE WHEN order_delivered_customer_date
             > order_estimated_delivery_date
             THEN 1 ELSE 0 END)          AS late_deliveries,
    ROUND(SUM(CASE WHEN order_delivered_customer_date
                   > order_estimated_delivery_date
                   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)         AS late_pct,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
              order_purchase_timestamp)), 1) AS avg_delivery_days
FROM orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

-- Q8. Top 10 sellers by revenue
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id)          AS orders_fulfilled,
    SUM(oi.order_item_id)                AS items_sold,
    ROUND(SUM(oi.price), 2)              AS total_revenue,
    ROUND(AVG(oi.price), 2)              AS avg_item_price
FROM order_items_dataset oi
JOIN orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Q9. Price segment analysis
SELECT
    CASE
        WHEN oi.price < 50   THEN 'Budget (under R$50)'
        WHEN oi.price < 200  THEN 'Mid (R$50-200)'
        WHEN oi.price < 500  THEN 'Premium (R$200-500)'
        ELSE 'Luxury (over R$500)'
    END                                  AS price_segment,
    COUNT(*)                             AS items,
    ROUND(AVG(oi.price), 2)              AS avg_price,
    ROUND(AVG(oi.freight_value), 2)      AS avg_freight,
    ROUND(SUM(oi.price), 2)              AS total_revenue
FROM order_items_dataset oi
GROUP BY price_segment
ORDER BY avg_price;

-- Q10. Customer repeat purchase rate
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time buyer'
        WHEN order_count = 2 THEN 'Returning (2 orders)'
        ELSE 'Loyal (3+ orders)'
    END                                  AS customer_type,
    COUNT(*)                             AS customers,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 1)        AS percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id)       AS order_count
    FROM customers_dataset c
    JOIN orders_dataset o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) t
GROUP BY customer_type
ORDER BY customers DESC;

-- Q11. Peak order hours
SELECT
    HOUR(order_purchase_timestamp)       AS hour_of_day,
    COUNT(*)                             AS orders,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders_dataset), 1) AS pct
FROM orders_dataset
GROUP BY HOUR(order_purchase_timestamp)
ORDER BY orders DESC
LIMIT 10;

-- Q12. Weekend vs weekday orders
SELECT
    CASE WHEN DAYOFWEEK(order_purchase_timestamp) IN (1,7)
         THEN 'Weekend' ELSE 'Weekday'
    END                                  AS day_type,
    COUNT(*)                             AS orders,
    ROUND(SUM(oi.price), 2)              AS revenue,
    ROUND(AVG(oi.price), 2)              AS avg_order_value
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY day_type;

-- Q13. Top 10 cities by customers
SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id)   AS unique_customers
FROM customers_dataset
GROUP BY customer_city, customer_state
ORDER BY unique_customers DESC
LIMIT 10;

-- Q14. Freight cost as % of order value by state
SELECT
    c.customer_state,
    ROUND(AVG(oi.price), 2)              AS avg_item_price,
    ROUND(AVG(oi.freight_value), 2)      AS avg_freight,
    ROUND(AVG(oi.freight_value /
        NULLIF(oi.price, 0)) * 100, 1)  AS freight_pct_of_price
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
JOIN customers_dataset c   ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY freight_pct_of_price DESC
LIMIT 10;


-- Q15. Revenue by quarter
SELECT
    YEAR(o.order_purchase_timestamp)     AS year,
    QUARTER(o.order_purchase_timestamp)  AS quarter,
    COUNT(DISTINCT o.order_id)           AS orders,
    ROUND(SUM(oi.price), 2)              AS revenue
FROM orders_dataset o
JOIN order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, quarter
ORDER BY year, quarter;





