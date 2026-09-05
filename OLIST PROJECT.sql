/*CREATE DATABASE olist_portfolio;*/
USE olist_portfolio;
/*DATA CLEANING*/

/*SET PK AND FK*?
ALTER TABLE OLIST_CUSTOMERS_DATASET
MODIFY customer_id VARCHAR (50),
MODIFY customer_unique_id VARCHAR (50);

ALTER TABLE OLIST_CUSTOMERS_DATASET
ADD PRIMARY KEY (customer_id);

ALTER TABLE OLIST_ORDER_ITEMS_DATASET
MODIFY order_id VARCHAR (50),
MODIFY order_item_id VARCHAR (50),
MODIFY product_id VARCHAR (50),
MODIFY seller_id VARCHAR (50),
MODIFY shipping_limit_date DATETIME;

ALTER TABLE OLIST_ORDER_ITEMS_DATASET
ADD PRIMARY KEY (order_item_id,order_id),
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES olist_orders_dataset(order_id),
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES olist_products_dataset(product_id),
ADD CONSTRAINT fk_seller
FOREIGN KEY (seller_id)
REFERENCES olist_sellers_dataset(seller_id);

ALTER TABLE OLIST_ORDER_PAYMENTS_DATASET
MODIFY order_id VARCHAR (50);

ALTER TABLE OLIST_ORDER_PAYMENTS_DATASET
ADD PRIMARY KEY (order_id,payment_sequential);

ALTER TABLE OLIST_ORDER_REVIEWS_DATASET
MODIFY order_id VARCHAR (50),
MODIFY review_id VARCHAR (50);

ALTER TABLE OLIST_ORDER_REVIEWS_DATASET
ADD CONSTRAINT fk_order_reviews_order_id
FOREIGN KEY (order_id)
REFERENCES olist_orders_dataset(order_id);

ALTER TABLE OLIST_ORDERS_DATASET
MODIFY order_id VARCHAR (50),
MODIFY customer_id VARCHAR (50);

ALTER TABLE OLIST_ORDERS_DATASET
ADD PRIMARY KEY (order_id),
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES olist_customers_dataset(customer_id);

ALTER TABLE OLIST_PRODUCTS_DATASET
MODIFY product_id VARCHAR (50);

ALTER TABLE OLIST_PRODUCTS_DATASET
ADD PRIMARY KEY (product_id);

ALTER TABLE OLIST_SELLERS_DATASET
MODIFY seller_id VARCHAR (50);

ALTER TABLE OLIST_SELLERS_DATASET
ADD PRIMARY KEY (seller_id);

-- ORDERS ANALYSIS
-- Analyze the count of orders in different statuses--
SELECT
	order_status,
	count(order_id) AS count_of_orders
FROM OLIST_ORDERS_DATASET
GROUP BY order_status
ORDER BY count_of_orders DESC;

-- Analyze the difference in esimated delivery vs actual delivery to identify delays.

CREATE VIEW delivery_analysis AS(
	SELECT
		order_id,
        customer_id,
		order_delivered_carrier_date,
		order_delivered_customer_date,
		order_estimated_delivery_date,
		DATEDIFF(order_delivered_customer_date,order_delivered_carrier_date) AS Carrier_days_to_delivery,
		DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS Delayed_deliveries
	FROM OLIST_ORDERS_DATASET
    WHERE order_status = 'delivered');

-- Analyze Avg days to delivery

SELECT 
	AVG(DATEDIFF(order_delivered_customer_date,order_approved_at)) AS Avg_delivery_days
 FROM OLIST_ORDERS_DATASET
 WHERE order_status = 'delivered';
 
SELECT
	*
FROM delivery_analysis
WHERE Delayed_deliveries > 0;

-- Pct of delivery delays
SELECT 
	count(order_id) AS Delayed_orders,
    (SELECT
		COUNT(order_id)
        FROM OLIST_ORDERS_DATASET
        WHERE order_status = 'delivered') AS Total_delivered,
        ROUND(count(order_id)/
        (SELECT
		COUNT(order_id)
        FROM OLIST_ORDERS_DATASET
        WHERE order_status = 'delivered')* 100,2) AS Delayed_Pct
FROM delivery_analysis
WHERE Delayed_deliveries > 0;

-- Relationship between delays and regions.
WITH Customers AS (
    SELECT
        A.customer_id,
        A.customer_zip_code_prefix,
        A.customer_city,
        A.customer_state,
        DATEDIFF(B.order_delivered_customer_date,B.order_estimated_delivery_date) AS Delayed_deliveries
	FROM OLIST_CUSTOMERS_DATASET A
	LEFT JOIN OLIST_ORDERS_DATASET B
	ON A.customer_id = B.customer_id
	WHERE B.order_status = 'delivered'
    )
SELECT
    customer_city,
    customer_state,
    count(*) As Total_Deliveries,
    SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) as Delayed_Deliveries,
	ROUND(SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) / count(*) * 100,2) AS Pct_Delays
FROM Customers
GROUP BY customer_city, customer_state
HAVING Total_Deliveries > 20
ORDER BY Pct_Delays DESC;

-- Delayed orders vs products category

With delayed_products AS (
	SELECT
		A.order_id,
        B.seller_id,
        B.product_id,
        DATEDIFF(A.order_delivered_customer_date,A.order_estimated_delivery_date) AS Delayed_deliveries
    FROM OLIST_ORDERS_DATASET A
    LEFT JOIN OLIST_ORDER_ITEMS_DATASET B 
    ON A.order_id = B.order_id
    WHERE A.order_status = 'delivered'
    )
    
SELECT 
    C.product_category_name,
    count(*) As Total_Deliveries,
    SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) as Delayed_Deliveries,
	ROUND(SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) / count(*) * 100,2) AS Pct_Delays
FROM delayed_products A
LEFT JOIN OLIST_PRODUCTS_DATASET C
ON A.product_id = C.product_id
GROUP BY product_category_name
ORDER BY Pct_Delays DESC;

-- Delayed orders vs seller cities

With delayed_orders AS (
	SELECT
		A.order_id,
        B.seller_id,
        B.product_id,
        DATEDIFF(A.order_delivered_customer_date,A.order_estimated_delivery_date) AS Delayed_deliveries
    FROM OLIST_ORDERS_DATASET A
    LEFT JOIN OLIST_ORDER_ITEMS_DATASET B 
    ON A.order_id = B.order_id
    WHERE A.order_status = 'delivered'
    )
    
SELECT 
    C.seller_city,
    C.seller_state,
    count(DISTINCT A.order_id) As Total_Deliveries,
    SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) as Delayed_Deliveries,
	ROUND(SUM(
		CASE WHEN Delayed_Deliveries > 0 THEN 1 
        ELSE 0
        END) / count(*) * 100,2) AS Pct_Delays
FROM delayed_orders A
LEFT JOIN OLIST_SELLERS_DATASET C
ON A.seller_id = C.seller_id
GROUP BY seller_city, seller_state
HAVING Total_Deliveries > 20
ORDER BY Pct_Delays DESC;

--Payment Type Breakdown and Value

SELECT
	Payment_type,
	COUNT(DISTINCT order_id) as Count,
    ROUND(SUM(payment_value)) as Value
FROM OLIST_ORDER_PAYMENTS_DATASET
GROUP BY payment_type
ORDER BY Value DESC;

--Revenue by customer_state + payment_type

WITH Customer_location AS (
	SELECT
		customer_state,
        payment_type,
        SUM(payment_value) AS Revenue
	FROM olist_orders_dataset A
    LEFT JOIN olist_customers_dataset B
    ON A.customer_id = B.customer_id
    LEFT JOIN olist_order_payments_dataset C
    ON A.order_id = C.order_id
    GROUP BY customer_state, payment_type
    )

SELECT
	customer_state,
    payment_type,
    Revenue,
    ROUND(Revenue / SUM(Revenue) OVER() * 100, 2) AS Pct_of_Total
FROM Customer_location
ORDER BY Revenue DESC;
        
--Freight cost as a % of product price

SELECT
	B.product_category_name,
    avg(A.price) AS Avg_Price,
    avg(A.freight_value) AS Avg_Freight_Value,
    avg(A.freight_value)/avg(A.price)*100 AS Freight_Price_Ratio
FROM olist_order_items_dataset A
LEFT JOIN olist_products_dataset B
ON A.product_id = B.product_id
GROUP BY product_category_name
ORDER BY Freight_Price_Ratio DESC;

--Freight cost as a % of product price(Item Level)
SELECT
	B.product_category_name,
    A.price,
    A.freight_value,
    A.freight_value/A.price AS Freight_Price_Ratio
FROM olist_order_items_dataset A
LEFT JOIN olist_products_dataset B
ON A.product_id = B.product_id
ORDER BY Freight_Price_Ratio DESC;

--Total Order Count by month

With Pivot_Data AS (
SELECT
	count(*) AS Total_Orders,
    Order_Status,
    monthname(order_purchase_timestamp) AS Order_Month,
    month(order_purchase_timestamp) AS Month,
    year(order_purchase_timestamp) AS Order_Year
FROM olist_orders_dataset 
GROUP BY Order_Month,Order_Year,Month,order_status)

SELECT
Order_Month,
sum(CASE WHEN Order_Year = 2016 THEN Total_Orders ELSE 0 END) AS `2016`,
sum(CASE WHEN Order_Year = 2017 THEN Total_Orders ELSE 0 END) AS `2017`,        
sum(CASE WHEN Order_Year = 2018 THEN Total_Orders ELSE 0 END) AS `2018`,
sum(Total_Orders) AS Total_Month_Orders
FROM Pivot_Data
WHERE Order_status = 'delivered'
GROUP BY Order_Month
ORDER BY Total_Month_Orders DESC

--Total Revenue by month

With Revenue_Data AS (
SELECT
    Order_Status,
    monthname(order_purchase_timestamp) AS Order_Month,
    month(order_purchase_timestamp) AS Month,
    year(order_purchase_timestamp) AS Order_Year,
    ROUND(SUM(Price+Freight_value),2) AS Revenue
FROM olist_orders_dataset A
LEFT JOIN olist_order_items_dataset B 
ON A.order_id = B.order_id
WHERE Order_status = 'delivered'
GROUP BY Order_Month,Order_Year,Month,order_status)

SELECT
Order_Month,
sum(CASE WHEN Order_Year = 2016 THEN Revenue ELSE 0 END) AS `2016`,
sum(CASE WHEN Order_Year = 2017 THEN Revenue ELSE 0 END) AS `2017`,        
sum(CASE WHEN Order_Year = 2018 THEN Revenue ELSE 0 END) AS `2018`,
Round(Sum(Revenue),2) AS Total_Revenue
FROM Revenue_Data
GROUP BY Order_Month
ORDER BY Total_Revenue DESC

--Customer Behaviour Analysis

SELECT
	customer_unique_id,
    count(order_id) AS Total_orders
FROM olist_customers_dataset A
LEFT JOIN olist_orders_dataset B
ON A.customer_id = B.customer_id
GROUP BY customer_unique_id
HAVING Total_orders > 1
ORDER BY Total_orders DESC

--Pct of Repeat customers

SELECT
    Total_Repeat_Customers,
    Total_Customers,
    ROUND(Total_Repeat_Customers / Total_Customers * 100, 2) AS Pct_of_Repeat_Customers
FROM (
    SELECT
        (SELECT COUNT(*)
         FROM (
             SELECT
                 customer_unique_id,
                 COUNT(order_id) AS Total_orders
             FROM olist_customers_dataset A
             LEFT JOIN olist_orders_dataset B
             ON A.customer_id = B.customer_id
             GROUP BY customer_unique_id
             HAVING COUNT(order_id) > 1
         ) AS Repeat_Customers
        ) AS Total_Repeat_Customers,

        (SELECT COUNT(DISTINCT customer_unique_id)
         FROM olist_customers_dataset
        ) AS Total_Customers
) AS Summary


--Revenue contribution: repeat vs. one-time customers

WITH Repeat_customers_revenue AS(
	SELECT
		C.Customer_unique_id,
        COUNT(DISTINCT A.order_id) AS Total_orders, 
        CASE WHEN
			COUNT(DISTINCT A.order_id) > 1 THEN 'Repeat_customers' ELSE 'Non-Returning_customers' END AS Customer_Category,
		ROUND(SUM(B.FREIGHT_VALUE+B.PRICE)) AS REVENUE
	FROM olist_orders_dataset A 
    LEFT JOIN olist_order_items_dataset B
    ON A.order_id = B.order_id
    LEFT JOIN olist_customers_dataset C
    ON A.customer_id = C.customer_id
    GROUP BY C.customer_unique_id)

SELECT
	Customer_category,
    SUM(Revenue) AS Total_Revenue,
    COUNT(*) AS Number_of_Customers,
    ROUND(SUM(Revenue)/COUNT(*),2) AS Avg_Revenue_per_Customer
FROM Repeat_customers_revenue 
GROUP BY Customer_category
ORDER BY Total_Revenue DESC;

		

--Review Score Analysis
--Delivery delay Impact on Review Score

SELECT
    CASE WHEN Delayed_deliveries > 0 THEN 'Delayed' ELSE 'On-Time' END AS Type_of_delivery,
    COUNT(*) AS Total_Reviews,
    AVG(review_score) AS Avg_Review_Score
FROM olist_order_reviews_dataset A
LEFT JOIN delivery_analysis B
ON A.order_id = B.order_id
WHERE Delayed_deliveries IS NOT NULL
GROUP BY CASE WHEN Delayed_deliveries > 0 THEN 'Delayed' ELSE 'On-Time' END
ORDER BY Avg_Review_Score;

--Review Score by Product and Seller
WITH Seller_Order_Reviews AS (
    SELECT DISTINCT
        A.seller_id,
        A.seller_city,
        A.seller_state,
        B.order_id,
        C.review_score
    FROM olist_sellers_dataset A
    JOIN olist_order_items_dataset B
    ON A.seller_id = B.seller_id
    JOIN olist_order_reviews_dataset C
    ON B.order_id = C.order_id
)

SELECT
    seller_id,
    seller_city,
    seller_state,
    AVG(review_score) AS Avg_Review_Score,
    COUNT(order_id) AS Total_Orders
FROM Seller_Order_Reviews
GROUP BY seller_id, seller_city, seller_state
HAVING Total_Orders > 20
ORDER BY Avg_Review_Score DESC;




