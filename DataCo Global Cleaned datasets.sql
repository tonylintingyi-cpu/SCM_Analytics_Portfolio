--Stage 1: Data Profiling
/* 1.1: Overview
	- Total number of row: 180,519
	- Total number of order: 65,752
	- Total number of customer: 20,652
	- Total number of products: 118
	- Earliest order date: 2015-01-01
	- Latest order date: 2018-01-31
	- Date time frame: 1126 days
	- Month time frame: 37 month 
*/

SELECT 
	COUNT(*) AS row_num,
	COUNT(DISTINCT "Order Id") AS ord_num, 
	COUNT(DISTINCT "Customer Id") AS cus_num,
	COUNT(DISTINCT "Product Card Id") AS pro_num,
	MIN(strptime("order date (DateOrders)", '%m/%d/%Y %H:%M')) AS earl_ordate, 
	MAX(strptime("order date (DateOrders)", '%m/%d/%Y %H:%M')) AS late_ordate, 
	late_ordate - earl_ordate AS day_time_frame, 
	EXTRACT(DAY FROM day_time_frame / 30) AS month_time_frame 
FROM main.raw_order ro;


-- Create a new table and rename columns for clarity
DROP TABLE IF EXISTS cleaned_order;
CREATE TABLE cleaned_order AS
SELECT
    -- ID: Unique Identifiers
    "Order Item Id" AS item_id,
    "Order Id" AS order_id,
    "Product Card Id" AS product_id,
    "Customer Id" AS customer_id,
    -- Logistics
    "Shipping Mode" AS shipping_mode,
    strptime("order date (DateOrders)", '%m/%d/%Y %H:%M') AS order_date,
    strptime("Shipping date (DateOrders)", '%m/%d/%Y %H:%M') AS shipping_date,
    "Days for shipping (real)" AS days_actual,
    "Days for shipment (scheduled)" AS days_scheduled,
    "Delivery Status" AS delivery_status,
    "Late_delivery_risk" AS late_risk,
    -- Order Info
    "Order Status" AS order_status,
    "Market" AS market,
    "Order Region" AS order_region,
    "Order Country" AS order_country,
    "Order State" AS order_state,
    "Order City" AS order_city,
    "Order Item Quantity" AS quantity,
    "Product Name" AS product_name,
    "Product Status" AS product_status,
    "Category Name" AS category_name,
    "Department Name" AS department_name,
    -- Customer Info
    "Customer City" AS customer_city,
    "Customer Country" AS customer_country,
    "Customer State" AS customer_state,
    "Customer Segment" AS customer_segment,
    "Latitude" AS latitude,
    "Longitude" AS longitude,
    -- Finance
    "Order Item Product Price" AS unit_price,
    "Sales" AS sales_gross,
    "Order Item Discount" AS discount_total,
    "Order Item Total" AS sales_net,
    "Order Profit Per Order" AS profit,
    "Type" AS payment_type
FROM main.raw_order;
	-- Data Type Validation
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cleaned_order';


/* 1.2: Missing Value Check
	- 0 null and blanks value in every column
*/
SELECT 
	-- ID
	SUM(CASE WHEN item_id IS NULL THEN 1 ELSE 0 END) AS item_id,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id,
	-- Logistics
	SUM(CASE WHEN TRIM(COALESCE(shipping_mode, '')) = '' THEN 1 ELSE 0 END) AS shipping_mode,
	SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date,
	SUM(CASE WHEN shipping_date IS NULL THEN 1 ELSE 0 END) AS shipping_date,
	SUM(CASE WHEN days_actual IS NULL THEN 1 ELSE 0 END) AS days_actual,
	SUM(CASE WHEN days_scheduled IS NULL THEN 1 ELSE 0 END) AS days_scheduled,
	SUM(CASE WHEN TRIM(COALESCE(delivery_status, '')) = '' THEN 1 ELSE 0 END) AS delivery_status,
	SUM(CASE WHEN late_risk IS NULL THEN 1 ELSE 0 END) AS late_risk,
	-- Order_Info
	SUM(CASE WHEN TRIM(COALESCE(order_status, '')) = '' THEN 1 ELSE 0 END) AS order_status,
	SUM(CASE WHEN TRIM(COALESCE(market, '')) = '' THEN 1 ELSE 0 END) AS market,
	SUM(CASE WHEN TRIM(COALESCE(order_region, '')) = '' THEN 1 ELSE 0 END) AS order_region,
	SUM(CASE WHEN TRIM(COALESCE(order_country, '')) = '' THEN 1 ELSE 0 END) AS order_country,
	SUM(CASE WHEN TRIM(COALESCE(order_state, '')) = '' THEN 1 ELSE 0 END) AS order_state,
	SUM(CASE WHEN TRIM(COALESCE(order_city, '')) = '' THEN 1 ELSE 0 END) AS order_city,
	SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity,
	SUM(CASE WHEN TRIM(COALESCE(product_name, '')) = '' THEN 1 ELSE 0 END) AS product_name,
	SUM(CASE WHEN product_status IS NULL THEN 1 ELSE 0 END) AS product_status,
	SUM(CASE WHEN TRIM(COALESCE(category_name, '')) = '' THEN 1 ELSE 0 END) AS category_name,
	SUM(CASE WHEN TRIM(COALESCE(department_name, '')) = '' THEN 1 ELSE 0 END) AS department_name,
	-- Customer Info
	SUM(CASE WHEN TRIM(COALESCE(customer_city, '')) = '' THEN 1 ELSE 0 END) AS customer_city,
	SUM(CASE WHEN TRIM(COALESCE(customer_country, '')) = '' THEN 1 ELSE 0 END) AS customer_country,
	SUM(CASE WHEN TRIM(COALESCE(customer_state, '')) = '' THEN 1 ELSE 0 END) AS customer_state,
	SUM(CASE WHEN TRIM(COALESCE(customer_segment, '')) = '' THEN 1 ELSE 0 END) AS customer_segment,
	SUM(CASE WHEN latitude IS NULL THEN 1 ELSE 0 END) AS latitude,
	SUM(CASE WHEN longitude IS NULL THEN 1 ELSE 0 END) AS longitude,
	-- Finance
	SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price,
	SUM(CASE WHEN sales_gross IS NULL THEN 1 ELSE 0 END) AS sales_gross,
	SUM(CASE WHEN discount_total IS NULL THEN 1 ELSE 0 END) AS discount_total,
	SUM(CASE WHEN sales_net IS NULL THEN 1 ELSE 0 END) AS sales_net,
	SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit,
	SUM(CASE WHEN TRIM(COALESCE(payment_type, '')) = '' THEN 1 ELSE 0 END) AS payment_type
FROM cleaned_order; 


/* 1.3: Duplicate Check
   - Grouping by (order_id, product_id, quantity, unit_price): 10,626 groups with duplicate_count between 2-5
   - After adding 'discount_total': 0 duplicates
   - Conclusion: 
   		No true duplicates, ~23% of records are same order+product with different discounts (valid business logic)
   		Some items have negative profit number.
*/
SELECT
    order_id, product_id, quantity, unit_price, discount_total,
    COUNT(*) AS duplicate_count
FROM cleaned_order
GROUP BY order_id, product_id, quantity, unit_price, discount_total
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

 
-- Stage 2: Data Validation

-- 2.1: Logic Consistency Check
	-- No shipping date is before order date
SELECT 
    COUNT(*) AS invalid_date_count 
FROM cleaned_order
WHERE shipping_date < order_date;
	-- Actual delivery date check
SELECT 
    COUNT(*) AS mismatch_count
FROM cleaned_order
WHERE days_actual != DATEDIFF('day', order_date, shipping_date);
 	-- No actual data errors found ~1,000 rows with diff 0.01-0.02 floating point precision issue
SELECT
	sales_net, (sales_gross - discount_total)
	FROM cleaned_order
WHERE ABS(sales_net - (sales_gross - discount_total)) > 0.02;


-- 2.2: Numerical Anomaly Check
	-- negative profit: 33,784 , 18.71%
SUMMARIZE cleaned_order;
SELECT 
    COUNT(*) AS negative_profit_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cleaned_order), 2) AS percentage
FROM cleaned_order
WHERE profit < 0 ;


-- Stage 3: Data Standardization

/* 3.1: Varchar Blanks Fix:
  	Affected rows
	- product_name: 1,774 (side blanks only)
	- category_name: 1,475 
	- order_region: 17,925 
 */ 
SELECT 
	SUM(CASE WHEN product_name != TRIM(product_name) OR product_name LIKE '%  %' THEN 1 ELSE 0 END) AS product_name_space,
	SUM(CASE WHEN category_name != TRIM(category_name) OR category_name LIKE '%  %' THEN 1 ELSE 0 END) AS category_name_space,
	SUM(CASE WHEN order_region != TRIM(order_region) OR order_region LIKE '%  %' THEN 1 ELSE 0 END) AS order_region_space
FROM cleaned_order;
	-- Fix 1: Trim side blanks
UPDATE cleaned_order
SET 
	product_name = TRIM(product_name),
	category_name = TRIM(category_name),
	order_region = TRIM(order_region)
WHERE 
	product_name != TRIM(product_name)
	OR category_name != TRIM(category_name)
	OR order_region != TRIM(order_region);
	-- Fix 2: Remove sequential spaces (product_name not affected)
UPDATE cleaned_order
SET 
    category_name = REPLACE(category_name, '  ', ' '),
    order_region = REPLACE(order_region, '  ', ' ')
WHERE 
    category_name LIKE '%  %'
    OR order_region LIKE '%  %';


-- 3.2: Categorical Consistency Check
SELECT 'shipping_mode' AS field, shipping_mode AS value, COUNT(*) AS cnt FROM cleaned_order GROUP BY shipping_mode
UNION ALL
SELECT 'order_status', order_status, COUNT(*) FROM cleaned_order GROUP BY order_status
UNION ALL
SELECT 'delivery_status', delivery_status, COUNT(*) FROM cleaned_order GROUP BY delivery_status
UNION ALL
SELECT 'customer_segment', customer_segment, COUNT(*) FROM cleaned_order GROUP BY customer_segment
UNION ALL
SELECT 'market', market, COUNT(*) FROM cleaned_order GROUP BY market
UNION ALL
SELECT 'payment_type', payment_type, COUNT(*) FROM cleaned_order GROUP BY payment_type;



