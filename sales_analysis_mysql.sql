-- Table Name => 'salesdata'
SELECT * FROM ms2024.salesdata;

-- Columns in salesdata 
SHOW COLUMNS FROM salesdata;

-- Calculate the total selling price and profits for all orders:

SELECT order_id ,CAST( sum(quantity*Selling_Price) as decimal(10,2 ) )as "Total Selling Price",
CAST(sum(quantity*unit_profit) as decimal(10,2)) as "Total Profit"
FROM salesdata
GROUP BY order_id
ORDER BY CAST(sum(quantity*unit_profit) as decimal(10,2)) desc;

-- Query to find all orders from the 'Technology' category 
-- that were shipped using 'Second Class' ship mode, ordered by order date.

SELECT order_id ,DATE(order_date),ship_mode,category
FROM salesdata
WHERE ship_mode="Second Class" AND category ="Technology"
ORDER BY (order_date);

-- Average Of orders city wise 

SELECT city, CAST(AVG(quantity*Selling_Price) AS DECIMAL(10,2))AS Average
FROM salesdata
GROUP BY city
ORDER BY average DESC;

-- find the TOP 10 city with the highest total quantity of products ordered.

SELECT city,sum(quantity) AS "Quantity"
FROM salesdata
GROUP BY city
ORDER BY Quantity DESC
LIMIT 10;

-- Rank orders in each region by quantity in descending order(TOP 5)

WITH ranked AS (
SELECT order_id,region,quantity,
DENSE_RANK() OVER (PARTITION BY region ORDER BY quantity DESC) AS "Place"
FROM salesdata)
SELECT *
FROM ranked
WHERE Place<=5;
 
 
 --  Sum of Qunatities in Month Wise
 
WITH year_wise AS
(
 SELECT YEAR(order_date) AS years,MONTH(order_date) as "months",sum(quantity) AS Quantities
 FROM salesdata
 GROUP BY YEAR(order_date), MONTH(order_date)
 ORDER BY MONTH(order_date) )
 SELECT months,
 SUM(CASE WHEN years=2022 THEN Quantities ELSE 0 END )AS year_2022,
 SUM(CASE WHEN years=2023 THEN Quantities ELSE 0 END) AS year_2023
 FROM year_wise
 GROUP BY months;
 
 -- TOP 10 Products Quantity Wise
 
 SELECT product_id,SUM(Quantity) AS total_quantity
 FROM salesdata
 GROUP BY product_id
 ORDER BY total_quantity DESC
 LIMIT 10;
 
 -- Highest Profit Product 
 
 WITH RANKED AS (
 SELECT product_id,CAST(SUM(total_profit) AS DECIMAL(10,2)) AS Total_profit,
 ROW_NUMBER() OVER ( ORDER BY SUM(total_profit) DESC) AS RANKS
 FROM salesdata
 GROUP BY product_id)
 SELECT *
 FROM RANKED
 WHERE RANKS<=10;
 
 -- high profit Products in each region
 
 WITH rnk AS (
 SELECT region,product_id,CAST(SUM(total_profit) AS DECIMAL (10,2)) AS profits,
 ROW_NUMBER() OVER (PARTITION BY Region ORDER BY SUM(total_profit) DESC) AS RANKS
 FROM salesdata
 GROUP BY region,product_id
 ORDER BY region)
 SELECT * 
 FROM rnk
 WHERE RANKS <=3;
 
 -- month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
 
 WITH year_cmp AS(
 SELECT YEAR(order_date) years,MONTH(order_date) as months,CAST(SUM(Selling_Price*Quantity)AS DECIMAL(10,2)) as sums
 FROM salesdata
 GROUP BY YEAR(order_date),MONTH(order_date)
 )
 SELECT months,
 SUM(CASE WHEN years=2022 THEN sums else 0 END) AS year_2022,
 SUM(CASE WHEN years=2023 THEN sums else 0 END ) AS year_2023
 FROM year_cmp
 GROUP BY months
 ORDER BY months;
 
 
 -- sub category had highest growth by sales in 2023 compare to 2022
 
 WITH subcat AS(
 SELECT sub_category,YEAR(order_date) AS years,CAST(sum(Selling_Price*Quantity) AS DECIMAL(10,2)) total
 FROM salesdata
 GROUP BY sub_category,YEAR(order_date)
 ORDER BY sum(Selling_Price*Quantity) DESC),
 sub2 AS(
 SELECT sub_category,
 SUM(CASE WHEN years=2022 THEN total ELSE 0 END )AS year2022,
 SUM(CASE WHEN years=2023 THEN total ELSE 0 END )AS year2023
 FROM subcat
 GROUP BY sub_category)
 SELECT *,
 (year2022-year2023) AS diff
 FROM sub2;
 