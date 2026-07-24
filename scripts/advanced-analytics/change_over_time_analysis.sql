/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/


-- Analyse sales performance over time
-- Quick Date Functions
SELECT
    dd.year AS order_year,
    dd.month AS order_month,
    SUM(fs.sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(fs.order_quantity) AS total_quantity
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_dates AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;


-- DATETRUNC()
SELECT
    DATETRUNC(month, dd.full_date) AS order_month,
    SUM(fs.sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(fs.order_quantity) AS total_quantity
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_dates AS dd
    ON fs.date_key = dd.date_key
GROUP BY DATETRUNC(month, dd.full_date)
ORDER BY order_month;

-- FORMAT()
SELECT
    FORMAT(dd.full_date, 'yyyy-MMM') AS order_year,
    SUM(fs.sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(fs.order_quantity) AS total_quantity
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_dates AS dd
    ON fs.date_key = dd.date_key
GROUP BY FORMAT(dd.full_date, 'yyyy-MMM') 
ORDER BY order_year;
