
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/


-- Retrieve a list of unique customer type
SELECT DISTINCT 
    customer_type 
FROM gold.dim_customers
ORDER BY customer_type;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;

-- Retrieve a list of unique group name, country/region code, and name
SELECT DISTINCT 
    group_name, 
    country_region_code, 
    name 
FROM gold.dim_territory 
ORDER BY group_name, country_region_code, name;

-- Retrieve a list of unique job title, sales person name
SELECT DISTINCT 
    job_title,
    full_name 
FROM gold.dim_sales_persons 
ORDER BY job_title, full_name ;
