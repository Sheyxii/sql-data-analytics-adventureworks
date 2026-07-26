
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


/*Segment products into cost ranges and 
count how many products fall into each segment*/
 
WITH product_segments AS (
	SELECT 
		product_key,
		product_name,
		standard_cost,
		CASE WHEN standard_cost < 100 THEN 'Below 100'
			 WHEN standard_cost BETWEEN 100  AND 500 THEN '100 - 500'
			 WHEN standard_cost BETWEEN 500  AND 1000 THEN '500 - 1000'
			 ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

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
ORDER BY total_customer DESC
