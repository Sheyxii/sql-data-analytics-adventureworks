/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/


-- Retrieve order date range and total days
SELECT 
    MIN(full_date) AS earliest_date,
    MAX(full_date) AS latest_date,
    COUNT(*) AS total_days
FROM gold.dim_dates;

-- Retrieve list of unique year
SELECT DISTINCT
    year
FROM gold.dim_dates
ORDER BY year;


-- Sanity Check for derived columns
SELECT TOP 20 
    full_date, 
    day, 
    month, 
    month_name, 
    quarter, year, 
    day_of_week, 
    week_of_year
FROM gold.dim_dates
ORDER BY full_date;
