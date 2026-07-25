/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare the contribution of different categories to the overall total.
    - To identify which categories dominate in terms of sales, customers, or quantity.
    - Useful for prioritization, resource allocation, or identifying high-impact segments.

SQL Functions Used:
    - SUM(): Aggregates values to get the whole (grand total).
    - Window Functions: SUM() OVER() to calculate the overall total across all rows.
===============================================================================
*/


-- Which categories contribute the most to overall customer count?
WITH category_sales AS (
	SELECT
		dp.category,
		COUNT(fs.customer_key) AS total_customers
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
		ON fs.product_key = dp.product_key
	GROUP BY dp.category
)

SELECT
	category,
	total_customers,
	SUM(total_customers) OVER () AS overall_sales,
	CONCAT(
		ROUND(CAST(total_customers AS FLOAT) / SUM(total_customers) OVER () *  100, 2),
		'%') AS pct_of_total
FROM category_sales
ORDER BY pct_of_total DESC;
