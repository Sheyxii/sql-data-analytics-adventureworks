
/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.
SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/


/*Segment products into three performance tiers based on their total sales revenue:
	- Best Seller: Products with total revenue of at least 50,000.
	- Moderate Seller: Products with total revenue between 10,000 and 49,999.
	- Low Seller: Products with total revenue below 10,000.
And find the total number of products by each segment
*/
WITH product_revenue AS (
	SELECT 
		dp.product_key,
		dp.product_name,
		SUM(fs.sales_amount) AS total_revenue,
		CASE WHEN SUM(fs.sales_amount) >= 50000 THEN 'Best Seller'
			 WHEN SUM(fs.sales_amount) BETWEEN 10000  AND 49999 THEN 'Moderate Seller'
			 ELSE 'Low Seller'
		END AS performance_segment
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
		ON fs.product_key = dp.product_key
	GROUP BY dp.product_key, dp.product_name
)
SELECT 
	performance_segment,
	COUNT(product_key) AS total_product
FROM product_revenue
GROUP BY performance_segment
ORDER BY total_product DESC;


/*Group individual customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of individual customers by each group
*/

WITH customer_spending AS (
	SELECT 
		dc.customer_key,
		SUM(fs.sales_amount) AS total_spending,
		MIN(dd.full_date) AS first_order,
		MAX(dd.full_date) AS last_order,
		DATEDIFF(MONTH, MIN(dd.full_date), MAX(dd.full_date)) AS lifespan
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_customers AS dc
		ON fs.customer_key = dc.customer_key
	LEFT JOIN gold.dim_dates AS dd
		ON fs.date_key = dd.date_key
	WHERE customer_type = 'Individual'
	GROUP BY dc.customer_key
)
SELECT
	customer_segments,
	COUNT(customer_key) AS total_customer
FROM (
	SELECT 
		customer_key,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending < 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segments
	FROM customer_spending
) AS segmented_customers
GROUP BY customer_segments
ORDER BY total_customer DESC;
