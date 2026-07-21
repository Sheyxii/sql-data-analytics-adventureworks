
-- Quick peek at the fact table structure/grain (not a measure itself)
SELECT * FROM gold.fact_sales;

-- Total number of items ordered across all sales
SELECT SUM(order_quantity) AS total_quantity
FROM gold.fact_sales;

-- Total revenue generated
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Total cost of products sold
SELECT SUM(total_product_cost) AS total_product_cost
FROM gold.fact_sales;

-- Total profit earned (sales - cost)
SELECT SUM(gross_profit) AS total_gross_profit
FROM gold.fact_sales;


-- Average selling price per unit
SELECT AVG(unit_price) AS avg_unit_price
FROM gold.fact_sales;

-- Average discount given per unit
SELECT AVG(unit_price_discount) AS avg_unit_price_dsc
FROM gold.fact_sales;

-- Average sales amount per line item
SELECT AVG(sales_amount) AS avg_sales
FROM gold.fact_sales;

-- Average standard (list) cost per unit
SELECT AVG(standard_cost) AS avg_standard_cost
FROM gold.fact_sales;

-- Average actual product cost per line item
SELECT AVG(total_product_cost) AS avg_product_cost
FROM gold.fact_sales;

-- Average profit per line item
SELECT AVG(gross_profit) AS avg_gross_profit
FROM gold.fact_sales;


-- Total number of sales line items (fact table grain = one row per product per order)
SELECT COUNT(sales_order_id) AS total_line_items
FROM gold.fact_sales;

-- Total number of DISTINCT orders (true order count, since one order spans multiple lines)
SELECT COUNT(DISTINCT sales_order_id) AS total_distinct_orders
FROM gold.fact_sales;

-- Find the total number of products
-- Using COUNT(*) instead of COUNT(product_name) so rows with a NULL name aren't dropped
SELECT COUNT(*) AS total_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS customers_with_orders
FROM gold.fact_sales;

-- Total sales orders assisted by a salesperson
SELECT COUNT(DISTINCT sales_order_id) AS total_assisted_orders
FROM gold.fact_sales
WHERE sales_person_key IS NOT NULL;

-- Total online sales orders
SELECT COUNT(DISTINCT sales_order_id) AS total_online_orders
FROM gold.fact_sales
WHERE sales_person_key IS NULL;


-- Sense-check: gross_profit should roughly equal sales_amount - total_product_cost
-- Flags rows where the two diverge, which can indicate data quality issues
SELECT COUNT(*) AS mismatched_profit_rows
FROM gold.fact_sales
WHERE gross_profit <> (sales_amount - total_product_cost);



-- Consolidated Report: all key metrics of the business in one result set
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(order_quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Total Product Cost', SUM(total_product_cost) FROM gold.fact_sales
UNION ALL
SELECT 'Total Gross Profit', SUM(gross_profit) FROM gold.fact_sales
UNION ALL
SELECT 'Avg Unit Price', AVG(unit_price) FROM gold.fact_sales
UNION ALL
SELECT 'Avg Unit Price Discount', AVG(unit_price_discount) FROM gold.fact_sales
UNION ALL
SELECT 'Total Distinct Orders', COUNT(DISTINCT sales_order_id) FROM gold.fact_sales
UNION ALL
SELECT 'Total Assisted Orders', COUNT(DISTINCT sales_order_id) FROM gold.fact_sales WHERE sales_person_key IS NOT NULL
UNION ALL
SELECT 'Total Online Orders', COUNT(DISTINCT sales_order_id) FROM gold.fact_sales WHERE sales_person_key IS NULL
UNION ALL
SELECT 'Total Products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Customers With Orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales;
