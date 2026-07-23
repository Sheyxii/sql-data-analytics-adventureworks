/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (products, customers, categories, etc.) based on performance metrics.
    - To identify top performers or laggards within a dataset.
    - For benchmarking and identifying outliers.
SQL Functions Used:
    - Window Ranking Functions: RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue;

-- Find the top 10 individual customers who have generated the highest revenue
SELECT TOP 10
    dc.name AS customer_name,
    SUM(fs.sales_amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rnk
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
WHERE customer_type = 'Individual'
GROUP BY dc.name
ORDER BY total_revenue DESC;

-- Find the 3 store customers with the fewest orders placed
SELECT TOP 3
    dc.name AS customer_name,
    COUNT(fs.sales_order_id) AS total_orders
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
WHERE customer_type = 'Store'
GROUP BY dc.name
ORDER BY total_orders ASC;
    

-- Rank products within each category by total revenue
SELECT 
    dp.product_key,
    dp.product_name,
    dp.category,
    SUM(fs.sales_amount) AS total_revenue,
    RANK() OVER (PARTITION BY dp.category ORDER BY SUM(fs.sales_amount) DESC) AS rnk
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_key, dp.category, dp.product_name
ORDER BY dp.category, rnk;

-- Rank salespersons by total revenue generated
SELECT 
    dsp.full_name AS sales_person_name,
    SUM(fs.sales_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rnk
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_sales_persons AS dsp
    ON fs.sales_person_key = dsp.sales_person_key
WHERE fs.sales_person_key IS NOT NULL
GROUP BY dsp.full_name
ORDER BY rnk;

-- Find the top-selling subcategory in each category
SELECT * 
FROM (
    SELECT 
        dp.subcategory,
        dp.category,
        SUM(fs.sales_amount) AS total_revenue,
        RANK() OVER (PARTITION BY dp.category ORDER BY SUM(fs.sales_amount) DESC) AS rnk
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.category, dp.subcategory
    ) ranked
WHERE rnk = 1;

-- Find the top 5 territories by total revenue
SELECT TOP 5
    dt.name AS territory,
    SUM(fs.sales_amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rnk
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_territory AS dt
    ON fs.territory_key = dt.territory_key
GROUP BY dt.name
ORDER BY rnk;
    
-- Identify the individual customer with the highest number of orders
SELECT *
FROM (
    SELECT 
        dc.name AS customer_name,
        COUNT(fs.sales_order_id) AS total_orders,
        ROW_NUMBER() OVER (ORDER BY COUNT(fs.sales_order_id) DESC) AS rnk
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
    WHERE customer_type = 'Individual'
    GROUP BY dc.name
) ranked
WHERE rnk = 1;

-- Find the product with the highest average selling price per category
SELECT *
FROM (
    SELECT
        dp.product_key,
        dp.product_name,
        dp.category,
        AVG(fs.unit_price) AS avg_selling_price,
        RANK() OVER (PARTITION BY dp.category ORDER BY AVG(fs.unit_price) DESC) AS rnk
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product_key, dp.product_name, dp.category
) ranked
WHERE rnk = 1;
