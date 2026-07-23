/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'AW_Analytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema 
    called gold and populates it by copying data directly from the existing 
    DataWarehouseAW.gold layer (same SQL Server instance).

WARNING:
    Running this script will drop the entire 'AW_Analytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
USE master;
GO
-- Drop and recreate the 'AW_Analytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'AW_Analytics')
BEGIN
    ALTER DATABASE AW_Analytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AW_Analytics;
END;
GO
-- Create the 'AW_Analytics' database
CREATE DATABASE AW_Analytics;
GO
USE AW_Analytics;
GO
-- Create Schema
CREATE SCHEMA gold;
GO

-- ===============================================================
-- Pull tables directly from DataWarehouseAW.gold into AW_Analytics.gold
-- SELECT INTO creates the table AND copies the data in one step
-- ===============================================================
IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL 
    DROP TABLE gold.dim_customers;
GO
SELECT * INTO gold.dim_customers 
FROM DataWarehouseAW.gold.dim_customers;
GO

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL 
    DROP TABLE gold.dim_products;
GO
SELECT * INTO gold.dim_products 
FROM DataWarehouseAW.gold.dim_products;
GO

IF OBJECT_ID('gold.dim_dates', 'U') IS NOT NULL 
    DROP TABLE gold.dim_dates;
GO
SELECT * INTO gold.dim_dates 
FROM DataWarehouseAW.gold.dim_dates;
GO

IF OBJECT_ID('gold.dim_sales_persons', 'U') IS NOT NULL 
    DROP TABLE gold.dim_sales_persons;
GO
SELECT * INTO gold.dim_sales_persons 
FROM DataWarehouseAW.gold.dim_sales_persons;
GO

IF OBJECT_ID('gold.dim_territory', 'U') IS NOT NULL 
    DROP TABLE gold.dim_territory;
GO
SELECT * INTO gold.dim_territory 
FROM DataWarehouseAW.gold.dim_territory;
GO

IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL 
    DROP TABLE gold.fact_sales;
GO
SELECT * INTO gold.fact_sales 
FROM DataWarehouseAW.gold.fact_sales;
GO
