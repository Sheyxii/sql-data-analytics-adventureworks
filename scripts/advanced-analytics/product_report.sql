/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors

Highlights:
    1. Gathers essential fields such as product name, category, subcategory,
       and cost.
    2. Segments products by revenue into High-Performer, Mid-Range, or
       Low-Performer.
    3. Aggregates product-level metrics:
           - total orders
           - total sales
           - total quantity sold
           - total customers (unique)
           - lifespan (in months)
           - total profit (sum of gross profit across all orders)
    4. Calculates valuable KPIs:
           - Recency (months since last sale)
           - Order Frequency
           - Average Order Revenue (AOR)
           - Average Monthly Revenue
           - Average Monthly Profit
           - Profit Margin %
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================


/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
WITH base_query AS (
    SELECT
        fs.sales_order_id,
        fs.sales_order_detail_id,
        fs.product_key,
        fs.customer_key,
        dp.product_name,
        dp.product_number,
        dd.full_date AS order_date,
        dp.product_id,
        dp.color,
        dp.size,
        dp.subcategory,
        dp.category,
        fs.order_quantity,
        fs.unit_price,
        fs.unit_price_discount,
        fs.sales_amount,
        fs.total_product_cost,
        fs.gross_profit
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    LEFT JOIN gold.dim_dates AS dd
        ON fs.date_key = dd.date_key

/*---------------------------------------------------------------------------
2) Product Aggregation: Summarize key metrics at the product level
---------------------------------------------------------------------------*/
), product_aggregation AS (
    SELECT
        product_key,
        product_name,
        product_number,
        product_id,
        color,
        size,
        category,
        subcategory,
        COUNT(DISTINCT sales_order_id) AS total_order,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(order_quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        SUM(total_product_cost) AS total_cost,
        SUM(gross_profit) AS total_profit,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(order_quantity, 0)),2) AS avg_selling_price,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        product_number,
        product_id,
        color,
        size,
        subcategory,
        category
)
/*---------------------------------------------------------------------------
3) Final Output: Apply segmentation and compute KPIs
   - product_segment (High-Performer / Mid-Range / Low-Performer) 
   - recency = months since last_order_date
   - order_frequency = total_orders / lifespan
   - avg_order_revenue = total_sales / total_orders
   - avg_monthly_revenue = total_sales / lifespan
   - avg_monthly_profit = total_profit / lifespan
   - profit_margin_pct = (total_profit / total_sales) * 100
---------------------------------------------------------------------------*/
SELECT TOP 100
    product_key,
    product_id,
    product_name,
    product_number,
    color,
    size,
    category,
    subcategory,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END product_segment,
    last_order_date,
    total_order,
    total_customers,
    total_quantity,
    total_sales,
    total_cost,
    total_profit,
    avg_selling_price,
    lifespan,
    ROUND(CAST(total_order AS FLOAT) / NULLIF(lifespan, 0), 2) AS order_frequency,
    ROUND(total_sales / NULLIF(total_order, 0), 2) AS avg_order_revenue
FROM product_aggregation


