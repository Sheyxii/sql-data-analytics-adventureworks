/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors
Highlights:
    1. Gathers essential fields such as customer name, ID, customer type,
       and transaction details.
    2. Segments customers into categories (VIP, Regular, New) based on
       spending and lifespan.
    3. Aggregates customer-level metrics:
           - total orders
           - total sales
           - total quantity purchased
           - total products
           - lifespan (in months)
           - total profit (sum of gross profit across all orders)
           - total discount given (sum of unit price discount x quantity)
    4. Calculates valuable KPIs:
           - Customer Segment
           - Recency
           - Purchase Frequency
           - Average Order Value
           - Average Quantity per Order
           - Average Monthly Spend
           - Average Monthly Profit
           - Profit Margin %
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS 

/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales and dim_customers
   - includes customer_type ('Store' or 'Individual') from dim_customers
   (join through dim_dates to get the actual order date, since fact_sales
   only stores date_key)
---------------------------------------------------------------------------*/
WITH base_query AS (
    SELECT 
        fs.sales_order_id,
        fs.sales_order_detail_id,
        fs.product_key,
        dd.full_date AS order_date,
        fs.order_quantity,
        fs.unit_price,
        fs.unit_price_discount,
        fs.sales_amount,
        fs.total_product_cost,
        fs.gross_profit,
        dc.customer_key,
        dc.customer_id,
        dc.name,
        dc.customer_type
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
    LEFT JOIN gold.dim_dates AS dd
        ON fs.date_key = dd.date_key

/*---------------------------------------------------------------------------
2) Customer Aggregation: Summarize key metrics at the customer level
   - carry customer_type through as a grouping column (one customer_type
     per customer_key, so it doesn't affect the aggregation)
   - total orders, total sales, total quantity, total distinct products
   - last order date and lifespan (months between first and last order)
---------------------------------------------------------------------------*/
), customer_aggregation AS (
SELECT
    customer_key,
    customer_id,
    name,
    customer_type,
    COUNT(DISTINCT sales_order_id) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(order_quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    SUM(gross_profit) AS  total_profit,
    SUM(unit_price_discount * order_quantity) AS total_discount_given,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
    customer_key,
    customer_id,
    name,
    customer_type
)
/*---------------------------------------------------------------------------
3) Final Output: Apply segmentation and compute KPIs
   - customer_segment (VIP / Regular / New) based on lifespan and total_sales
   - recency = months since last order date
   - purchase_frequency = total_order / lifespan
   - avg_order_value = total_sales / total_order
   - avg_quantity_per_order = total_quantity / total_order
   - avg_monthly_spend = total_sales / lifespan
   - avg_monthly_profit = total_profit / lifespan
   - profit_margin_pct = (total_profit / total_sales) * 100
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_id,
    name,
    customer_type,
    CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_sales < 5000 THEN 'Regular' 
         ELSE 'New'
    END AS customer_segment,
    last_order_date,
    total_order,
    total_sales,
    total_quantity,
    total_product,
    total_discount_given,
    total_profit,
    lifespan,
    ROUND(CAST(total_order AS FLOAT) / NULLIF(lifespan, 0), 2) AS purchase_frequency,
    CASE WHEN total_sales = 0 THEN 0
	     ELSE total_sales / total_order
    END AS avg_order_value,
    ROUND(CAST(total_quantity AS FLOAT) / total_order , 2) AS avg_quantity_per_order,
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan , 2) 
    END AS avg_monthly_spend,
    CASE WHEN lifespan = 0 THEN total_profit
         ELSE ROUND(CAST(total_profit AS FLOAT) / lifespan , 2) 
    END AS avg_monthly_profit,
    (total_profit / total_sales) * 100 AS profit_margin_pct
FROM customer_aggregation;
