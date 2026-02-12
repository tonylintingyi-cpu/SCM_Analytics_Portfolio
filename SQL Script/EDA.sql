-- Data Quality Check: Identify canceled orders to be excluded from analysis
	-- 2,855 orders (4.34% of total) will be filtered out
SELECT delivery_status, 
       COUNT(DISTINCT order_id) AS order_count
FROM cleaned_order
WHERE delivery_status = 'Shipping canceled'
GROUP BY delivery_status;


-- view 1: v_order_performance_base
DROP VIEW IF EXISTS v_order_performance_base;

CREATE VIEW v_order_performance_base AS
SELECT
	-- key id
	order_id,
	-- time
	ANY_VALUE(order_date) AS order_date,
	-- logistics performance
	ANY_VALUE(days_scheduled) AS days_scheduled,
	ANY_VALUE(days_actual) AS days_actual,
	ANY_VALUE(delivery_status) AS delivery_status,
	CASE WHEN ANY_VALUE(delivery_status) IN ('Advance shipping', 'Shipping on time') THEN 'Yes'
		WHEN ANY_VALUE(delivery_status) = ('Late delivery') THEN 'No'
	END AS is_on_time, -- add is_on_time field
	ANY_VALUE(shipping_mode) AS shipping_mode,
	-- geographical dimension
    ANY_VALUE(market) AS market,
    ANY_VALUE(order_country) AS order_country,
    -- profit
    ROUND(SUM(profit), 2) AS order_profit
FROM cleaned_order
WHERE delivery_status != 'Shipping canceled' -- excluding canceled order
GROUP BY order_id;

-- Verify view creation: should have 62,897 orders (total - canceled)
SELECT COUNT(DISTINCT order_id) FROM v_order_performance_base;

-- KPI metrics
	/*
	 Advance shipping: 24.05%
	 Shipping on time: 18.64%
	 Late delivery: 57.31%
	 */

SELECT 
	delivery_status,
	COUNT(*),
	ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 2) AS percentage
FROM v_order_performance_base
GROUP BY delivery_status;

	/*average delivery days
 	overall_avg: 3.5 days
 	on-time_avg: 2.71 days
 	delayed_avg: 4.09 days
 	*/
SELECT 
    ROUND(AVG(days_actual),2) AS overall_avg_days, 
    ROUND(AVG(CASE WHEN is_on_time = 'Yes' THEN days_actual END),2) AS ontime_avg_days, 
    ROUND(AVG(CASE WHEN is_on_time = 'No' THEN days_actual END),2) AS late_avg_days   
FROM v_order_performance_base;

-- distribution of delayed days: how many days are orders typically late?
-- One and two-day orders account for most of the delivery.
SELECT 
	(days_actual - days_scheduled) AS delayed_days,
	COUNT(order_id)
FROM v_order_performance_base
GROUP BY  (days_actual - days_scheduled)
HAVING (days_actual - days_scheduled) > 0
ORDER BY delayed_days;

-- market delivery efficiency
-- all market shares around 42~43% of on-time delivery rate
SELECT market,
	SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) AS ontime_order_num,
	COUNT(*) AS total_count,
	ROUND(SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS ontime_rate
FROM v_order_performance_base
GROUP BY market;

-- shipping mode efficiency
-- First Class (0%) and Second Class (20%) severely underperform
SELECT 
    shipping_mode,
    SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) AS ontime_count,
    COUNT(*) AS total_count,
    ROUND(SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ontime_rate
FROM v_order_performance_base
GROUP BY shipping_mode
ORDER BY ontime_rate DESC;

-- First Class delivery performance: scheduled vs actual days
-- 100% consistency: all orders promised 1 day but delivered in 2 days
SELECT 
    days_actual,
    days_scheduled,
    COUNT(*) AS order_count
FROM v_order_performance_base
WHERE shipping_mode = 'First Class'
GROUP BY days_actual, days_scheduled;


-- Second Class delivery performance: scheduled vs actual days
-- Unlike First Class (consistent 1-day delay), Second Class has variable delays (1-4 days)
SELECT 
    days_actual,
    days_scheduled,
    COUNT(*) AS order_count
FROM v_order_performance_base
WHERE shipping_mode = 'Second Class'
GROUP BY days_actual, days_scheduled;

-- Second Class: ~20% on-time rate globally, with minimal country-level variation
-- All markets show ~20% on-time rate with ~4 days average delivery
SELECT 
    market,
    ROUND(SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ontime_rate,
    AVG(days_actual) AS avg_actual_days
FROM v_order_performance_base
WHERE shipping_mode = 'Second Class'
GROUP BY market
ORDER BY ontime_rate ASC;
-- Identify top-performing countries for Second Class to verify if success clusters in specific regions
-- Even best performers (Russia 28.57%, Panama 27.19%) remain below 30%
SELECT
    order_country,
    ROUND(SUM(CASE WHEN is_on_time = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ontime_rate
FROM v_order_performance_base
WHERE shipping_mode = 'Second Class'
GROUP BY order_country
HAVING COUNT(*) >= 50  
ORDER BY ontime_rate DESC
LIMIT 10;



-- Category ABC Classification: identify profit contribution tiers
-- Custom threshold: A-class = top 85% (adjusted from standard 80% based on observed profit gaps)
DROP VIEW IF EXISTS v_category_abc_analysis;
CREATE VIEW v_category_abc_analysis AS
SELECT
	category_name,
	total_profit,
	ROUND(SUM(total_profit) OVER(ORDER BY total_profit DESC), 0) AS cumulative_profit,
	ROUND(cumulative_profit * 100 / SUM(total_profit) OVER(), 2) AS cumulative_percentage,
	CASE 
		WHEN cumulative_percentage <= 85.00 THEN 'A'
		WHEN cumulative_percentage <= 95.00 THEN 'B'
		ELSE 'C'
	END AS abc_class
FROM(
	SELECT 
		category_name, 
		ROUND(SUM(profit), 0) AS total_profit
	FROM cleaned_order
	GROUP BY category_name
)AS category_totals;

	
-- products that are lossing profit
/*
 there are three products that have a negative of total profit:
 - SOLE E35 Elliptical
 - Bushnell Pro X7 Jolt Slope Rangefinder
 - SOLE E25 Elliptical
 */
SELECT
    product_name,
    ROUND(SUM(profit),2) AS total_profit,
    MAX(profit) AS best_transaction,   
    MIN(profit) AS worst_transaction,  
    ROUND(AVG(profit),2) AS avg_profit_per_item
FROM cleaned_order
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit;





