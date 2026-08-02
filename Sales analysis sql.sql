-- Databricks notebook source
----------------------------------------------------------------------------------------------------viewing the whole table before i start doing analysis
---------------------------------------------------------------------------------------------SELECT *
FROM sales_case_study.fnb_sales.sales;
-------------------------------------------------------------------------------------------------Checking the size of the data and if there are duplicates records in the data
---------------------------------------------------------------------------------------------
SELECT count (*)
FROM sales_case_study.fnb_sales.sales;

SELECT count (DISTINCT Date)
FROM sales_case_study.fnb_sales.sales;
-----------------------------------------------------------------------------------------------checking for null in each colomn
-----------------------------------------------------------------------------------------
SELECT COUNT(*)
FROM sales_case_study.fnb_sales.sales
WHERE Date IS NULL;

SELECT COUNT(*)
FROM sales_case_study.fnb_sales.sales
WHERE Sales IS NULL;

SELECT COUNT(*)
FROM sales_case_study.fnb_sales.sales
WHERE `Cost Of Sales` IS NULL;

SELECT COUNT(*)
FROM sales_case_study.fnb_sales.sales
WHERE `Quantity Sold`IS NULL;
----------------------------------------------------------------------------------------------------calculating Daily Sales Price Per Unit
------------------------------------------------------------------------------------------
SELECT
    Date,
    Sales,
    `Quantity Sold`,
    ROUND(Sales / `Quantity Sold`, 2) AS Daily_Unit_Sales_Price
FROM sales_case_study.fnb_sales.sales;
--------------------------------------------------------------------------------
--calculating Average Unit Sales Price
-------------------------------------------------------------------------------
SELECT
    ROUND(
        SUM(Sales) / SUM(`Quantity Sold`),
        2
    ) AS Average_Unit_Sales_Price
FROM sales_case_study.fnb_sales.sales;
--------------------------------------------------------------------------------
--calculating daily % gross profit
-------------------------------------------------------------------------------
SELECT
    Date,
    Sales,
    `Cost Of Sales`,
    Sales - `Cost Of Sales` AS Gross_Profit
FROM sales_case_study.fnb_sales.sales;

SELECT
    Date,
    ROUND(
        ((Sales - `Quantity Sold`) / Sales) * 100,
        2
    ) AS Gross_Profit_Percentage
FROM sales_case_study.fnb_sales.sales;
--------------------------------------------------------------------------------
--calculating daily % gross profit per unit
-------------------------------------------------------------------------------
SELECT
    Date,
    ROUND(
        (Sales - `Cost Of Sales`) / `Quantity Sold`,
        2
    ) AS Gross_Profit_Per_Unit
FROM sales_case_study.fnb_sales.sales;

SELECT
    Date,
    ROUND(
        (
            ((Sales - `Cost Of Sales`) / `Quantity Sold`)
            /
            (Sales / `Quantity Sold`)
        ) * 100,
        2
    ) AS Daily_Gross_Profit_Per_Unit_Percentage
FROM sales_case_study.fnb_sales.sales;

SELECT
    Date,
    ROUND(
        Sales / `Quantity Sold`,
        2
    ) AS Unit_Price,
    `Quantity Sold`
FROM sales_case_study.fnb_sales.sales;

-- Date Columns
SELECT
        YEAR(Date) AS year,
        MONTHNAME(Date) AS month_name,
        DAYNAME(Date) AS day_name
FROM sales_case_study.fnb_sales.sales;



WITH sales_analysis AS (

    
    SELECT
Date,
     YEAR(Date) AS year,
        MONTHNAME(Date) AS month_name,
        DAYNAME(Date) AS day_name,
        
        Sales,
        `Cost Of Sales`,
        `Quantity Sold`,

        -- Daily Unit Sales Price
        ROUND(
            Sales / `Quantity Sold`,
            2
        ) AS Daily_Unit_Sales_Price,

        -- Gross Profit
        ROUND(
            Sales - `Cost Of Sales`,
            2
        ) AS Gross_Profit,

        -- Gross Profit Percentage
        ROUND(
            ((Sales - `Cost Of Sales`) / Sales) * 100,
            2
        ) AS Gross_Profit_Percentage,

        -- Gross Profit Per Unit
        ROUND(
            (Sales - `Cost Of Sales`) / `Quantity Sold`,
            2
        ) AS Gross_Profit_Per_Unit,

        -- Gross Profit Percentage Per Unit
         ROUND(
    ((Sales - `Cost Of Sales`) / `Cost Of Sales`) * 100,
    2
) AS Gross_Profit_Per_Unit_Percentage,

       

        -- Previous day's unit price
        LAG(ROUND(Sales / `Quantity Sold`, 2))
            OVER (ORDER BY Date) AS Previous_Unit_Price,

        -- Previous day's quantity sold
        LAG(`Quantity Sold`)
            OVER (ORDER BY Date) AS Previous_Quantity,

  
    CASE

        -- Unit price decreases and quantity sold increases
        WHEN Daily_Unit_Sales_Price < Previous_Unit_Price
             AND `Quantity Sold` > Previous_Quantity
        THEN 'Promotion'

        -- Unit price remains constant
        WHEN Daily_Unit_Sales_Price = Previous_Unit_Price
        THEN 'No Promotion'

        -- Unit price increases
        WHEN Daily_Unit_Sales_Price> Previous_Unit_Price
        THEN 'No Promotion'

        -- Unit price decreases and quantity sold decreases
        WHEN Daily_Unit_Sales_Price < Previous_Unit_Price
             AND `Quantity Sold` < Previous_Quantity
        THEN 'No Promotion'

        -- First row or anything else
        ELSE 'Unable to Determine'

    END AS Promotion_Status

        

    FROM sales_case_study.fnb_sales.sales
)

SELECT *
FROM sales_analysis;
