/*
===============================================================================
Territory Report
===============================================================================
Purpose:
    - This report consolidates key territory-level sales metrics and behaviors
Highlights:
    1. Gathers essential fields such as territory ID, name, country/region,
       and group classification.
    2. Segments territories into categories (Top Performer, Moderate
       Performer, Underperformer) based on total sales and profit margin.
    3. Aggregates territory-level metrics:
           - total orders
           - total sales
           - total quantity purchased
           - total distinct products sold
           - lifespan (in months)
           - total profit (sum of gross profit across all orders)
           - total discount given (sum of unit price discount x quantity)
    4. Calculates valuable KPIs:
           - Territory Segment
           - Purchase Frequency
           - Average Order Value
           - Average Quantity per Order
           - Average Monthly Spend
           - Average Monthly Profit
           - Profit Margin %
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_territory
-- =============================================================================


/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales, dim_territory, dim_dates
---------------------------------------------------------------------------*/
WITH base_query AS (
    SELECT 
        dt.territory_key,
        dt.territory_id,
        dt.name,
        dt.country_region_code,
        dt.group_name,
        fs.sales_order_id,
        fs.sales_order_detail_id,
        fs.product_key,
        dd.full_date AS order_date,
        fs.order_quantity,
        fs.unit_price,
        fs.unit_price_discount,
        fs.sales_amount,
        fs.total_product_cost,
        fs.gross_profit
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_territory AS dt
        ON fs.territory_key = dt.territory_key
    LEFT JOIN gold.dim_dates AS dd
        ON fs.date_key = dd.date_key

/*---------------------------------------------------------------------------
2) Territory Aggregation: Summarize key metrics at the territory level
---------------------------------------------------------------------------*/
), territory_aggregation AS (
    SELECT 
        territory_key,
        territory_id,
        name,
        country_region_code,
        group_name,
        COUNT(DISTINCT sales_order_id) AS total_order,
        SUM(sales_amount) AS total_sales,
        SUM(order_quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_product,
        SUM(gross_profit) AS total_profit,
        SUM(unit_price_discount * order_quantity) AS total_discount_given,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        territory_key,
        territory_id,
        name,
        country_region_code,
        group_name
)

/*---------------------------------------------------------------------------
3) Final Output: Apply segmentation and compute KPIs
   - territory_segment (Top Performer / Moderate Performer / Underperformer)
     based on total_sales and profit_margin_pct, since lifespan doesn't vary
     enough across territories to be a useful segmentation input here
   - purchase_frequency = total_order / lifespan
   - avg_order_value = total_sales / total_order
   - avg_quantity_per_order = total_quantity / total_order
   - avg_monthly_spend = total_sales / lifespan
   - avg_monthly_profit = total_profit / lifespan
   - profit_margin_pct = (total_profit / total_sales) * 100
---------------------------------------------------------------------------*/
SELECT
    territory_id,
    name,
    country_region_code,
    group_name,
    CASE WHEN total_sales > 10000000 AND (total_profit / NULLIF(total_sales, 0)) > 0.05 THEN 'Top Performer'
         WHEN (total_profit / NULLIF(total_sales, 0)) < 0 THEN 'Underperformer'
         ELSE 'Moderate Performer'
    END AS territory_segment,
    last_order_date,
    total_order,
    total_sales,
    total_quantity,
    total_product,
    total_discount_given,
    total_profit,
    lifespan,
    ROUND(CAST(total_order AS FLOAT) / NULLIF(lifespan, 0), 2) AS purchase_frequency,
    ROUND(total_sales / NULLIF(total_order, 0), 2) AS avg_order_value,
    ROUND(CAST(total_quantity AS FLOAT) / NULLIF(total_order, 0), 2) AS avg_quantity_per_order,
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
    END AS avg_monthly_spend,
    CASE WHEN lifespan = 0 THEN total_profit
         ELSE ROUND(CAST(total_profit AS FLOAT) / lifespan, 2)
    END AS avg_monthly_profit,
    ROUND((total_profit / NULLIF(total_sales, 0)) * 100, 2) AS profit_margin_pct
FROM territory_aggregation;
