/*
===============================================================================
Performance Analysis (Year-over-Year (YoY), Difference From Average)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/



/*
	Analyze the yearly performance of products by comparing their sales 
	to both its average sales performance and the previous year's sales
*/

WITH yearly_product_sales AS (
	SELECT 
		dd.year AS order_year,
		dp.product_name,
		SUM(fs.sales_amount) AS current_sales
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_dates AS dd
		ON fs.date_key = dd.date_key
	LEFT JOIN gold.dim_products AS dp
		ON fs.product_key = dp.product_key
	GROUP BY dd.year, dp.product_name
)

SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name ) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_from_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		 ELSE 'Average'
	END AS avg_change,
	-- Year-over-Year Analysis (YoY)
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END as prev_year_change
FROM yearly_product_sales




