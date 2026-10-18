-- Retail Sales Analytics: MySQL schema and analysis queries
-- Run: mysql -u root -p < sql/retail_analysis.sql  (after placing clean_sales.csv in a path MySQL can read)

CREATE DATABASE IF NOT EXISTS retail_bi;
USE retail_bi;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    order_id    VARCHAR(20) PRIMARY KEY,
    order_date  DATE,
    customer_id VARCHAR(20),
    segment     VARCHAR(20),
    region      VARCHAR(20),
    category    VARCHAR(30),
    product     VARCHAR(40),
    quantity    INT,
    unit_price  DECIMAL(10,2),
    discount    DECIMAL(4,2),
    unit_cost   DECIMAL(10,2),
    sales       DECIMAL(12,2),
    profit      DECIMAL(12,2),
    month       CHAR(7),
    year        INT
);

-- Load the cleaned file (edit the path; or use MySQL Workbench > Table Data Import Wizard)
-- LOAD DATA LOCAL INFILE 'data/clean_sales.csv' INTO TABLE sales
-- FIELDS TERMINATED BY ',' IGNORE 1 LINES;

-- 1. Overall KPIs
SELECT COUNT(*) AS orders, ROUND(SUM(sales),2) AS total_sales, ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct, ROUND(AVG(sales),2) AS avg_order_value
FROM sales;

-- 2. Sales and margin by category
SELECT category, ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct
FROM sales GROUP BY category ORDER BY sales DESC;

-- 3. Top 5 products and their share of total sales
SELECT product, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(sales)/(SELECT SUM(sales) FROM sales)*100,2) AS share_pct
FROM sales GROUP BY product ORDER BY sales DESC LIMIT 5;

-- 4. Monthly sales with month-over-month growth (window function)
SELECT month, ROUND(SUM(sales),2) AS sales,
       ROUND((SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY month))
             / LAG(SUM(sales)) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM sales GROUP BY month ORDER BY month;

-- 5. Region performance ranked by profit
SELECT region, ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM sales GROUP BY region;

-- 6. Customer segment contribution
SELECT segment, COUNT(DISTINCT customer_id) AS customers, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct
FROM sales GROUP BY segment ORDER BY sales DESC;

-- 7. Discount impact on profit margin
SELECT CASE WHEN discount = 0 THEN '0%' WHEN discount <= 0.10 THEN '1-10%'
            WHEN discount <= 0.20 THEN '11-20%' ELSE '21-30%' END AS discount_band,
       COUNT(*) AS orders, ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct
FROM sales GROUP BY discount_band ORDER BY margin_pct DESC;

-- 8. Top 10 customers by sales (JOIN-free repeat-buyer view)
SELECT customer_id, COUNT(*) AS orders, ROUND(SUM(sales),2) AS sales
FROM sales GROUP BY customer_id HAVING COUNT(*) > 1 ORDER BY sales DESC LIMIT 10;
