

 -- E-Commerce_Sales_Analysis\
# \Sql Queries \


-- 1. View First 100 Records

SELECT *
FROM sales_data
LIMIT 100;

-- 2. Total Number of Records

SELECT COUNT(*) AS total_records
FROM sales_data;

-- 3. Total Revenue Generated

SELECT SUM(quantity * price) AS total_revenue
FROM sales_data;

-- 4. Total Quantity Sold

SELECT SUM(quantity) AS total_items_sold
FROM sales_data;

-- 5. Average Product Price

SELECT AVG(price) AS average_price
FROM sales_data;

-- 6. Total Sales by Product

SELECT product_name,
       SUM(quantity) AS total_quantity_sold
FROM sales_data
GROUP BY product_name
ORDER BY total_quantity_sold DESC;

-- 7. Revenue by Product

SELECT product_name,
       SUM(quantity * price) AS total_revenue
FROM sales_data
GROUP BY product_name
ORDER BY total_revenue DESC;

-- 8. Top 5 Best Selling Products

SELECT product_name,
       SUM(quantity) AS total_sales
FROM sales_data
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;

-- 9. Bottom 5 Least Selling Products

SELECT product_name,
       SUM(quantity) AS total_sales
FROM sales_data
GROUP BY product_name
ORDER BY total_sales ASC
LIMIT 5;

-- 10. Highest Price Product

SELECT product_name, price
FROM sales_data
ORDER BY price DESC
LIMIT 1;

-- 11. Products Generating Revenue Above Average

SELECT product_name,
      SUM(quantity * price) AS total_revenue
FROM sales_data
GROUP BY product_name
HAVING SUM(quantity * price) >
(
    SELECT AVG(quantity * price)
    FROM sales_data
);

-- 12. Product Sales Ranking

SELECT product_name,
       SUM(quantity) AS total_sales
FROM sales_data
GROUP BY product_name
ORDER BY total_sales DESC;
