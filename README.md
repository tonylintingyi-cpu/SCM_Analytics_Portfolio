# DataCo Global: Shipping Performance & Product Profitability Analysis

## Project Background

DataCo Global is a virtual international e-commerce retailer operating across the United States, Europe, Latin America, and the Asia-Pacific region. The company processes tens of thousands of orders annually across diverse product categories — including sporting goods, consumer electronics, apparel, and home goods — fulfilled through multiple shipping tiers (Standard, Same Day, First Class, Second Class).

This project analyses DataCo's **order and shipping performance data** to uncover delivery reliability issues, identify revenue-driving product segments, and surface actionable opportunities for logistics optimisation. Key areas of focus include:

- Shipping delay patterns across delivery methods
- Fulfilment SLA accuracy by shipping tier
- Product category contribution to profit and sales volume

The SQL queries for data cleaning are available [here](https://github.com/tonylintingyi-cpu/Logistics_and_ABC_Analysis/blob/4fe69f1232383b70fa54190c0ecf43dd28cec3a0/SQL%20Script/Data%20Cleaning.sql).  
The SQL queries for exploratory data analysis are available [here](https://github.com/tonylintingyi-cpu/Logistics_and_ABC_Analysis/blob/4fe69f1232383b70fa54190c0ecf43dd28cec3a0/SQL%20Script/EDA.sql).


## Data Structure Overview

DataCo Global's datasets have one table that includes 52 columns and 180,519 rows. To enhance recognition of the column title, I created a cleaned_order table with a changed column title. For analytics purposes in Tableau, two views were created from the cleaned_order table.

<img width="833" height="641" alt="截圖 2026-02-12 下午2 09 58" src="https://github.com/user-attachments/assets/deb4f5cb-af9e-460c-aaa3-e5d31a4c3969" />


The SQL queries for a variety of data quality checks can be found [here](https://github.com/tonylintingyi-cpu/Logistics_and_ABC_Analysis/blob/eea9ce9e5776d9c94e4159aa1634f604048ed74e/SQL%20Script/Data%20Cleaning.sql).


## Executive Summary

The company's delivery performance reveals a systematic fulfilment issue: **over 80% of orders experience 1–2 days of delay**, signaling operational gaps across shipping tiers.

- **First Class shipping** suffers from consistent overcommitment — every order is delayed by exactly 1 day, suggesting the promised delivery window is structurally unrealistic.
- **Second Class shipping** shows greater variability, with delays ranging from 1 to 4 days, indicating less predictable bottlenecks in the fulfilment pipeline.
- Applying the **Pareto principle**, 8 product categories drive **85% of total profit**, while the remaining categories contribute minimally to both profit and sales volume — presenting an opportunity to prioritise logistics resources toward high-impact categories.

[Executive Summary Dashboard](https://public.tableau.com/app/profile/tony.lin4499/viz/LogisticsABCAnalysis/LogisticsABCAnalysis)


## Insights Deep Dive

### Logistics Performance

The overall on-time delivery rate is only **42.69%**, meaning more than half of all orders arrive late. The average delay is 1.62 days, and most delayed orders (58.68%) are just 1 day late.

Performance varies significantly by shipping mode. Standard Class performs best at **60.15%** on-time, followed by Same Day at **51.63%**. The two underperformers are:

- **First Class has a 0% on-time rate.** Every order is promised 1-day delivery but takes 2 days. This isn't a random delay — it's a consistent 1-day gap, which means the promised delivery window is simply set too tight.
- **Second Class has a 20.01% on-time rate**, with delays ranging from 1 to 4 days. Unlike First Class, the delay pattern here is unpredictable. This issue is not region-specific — all markets show roughly the same ~20% on-time rate, and even the best-performing countries stay below 30%.

<img width="2030" height="1622" alt="Logistics   ABC Analysis拷貝" src="https://github.com/user-attachments/assets/9bd5d979-ac16-4238-8e25-0e3645808953" />
<img width="2030" height="1625" alt="Logistics   ABC Analysis (1)" src="https://github.com/user-attachments/assets/b0aae7ab-2837-4f71-b661-50d77805141f" />

### Product Category Profitability

Using ABC analysis, **8 out of 40+ categories account for 85% of total profit** (Class A). These include Fishing, Cleats, Camping & Hiking, Cardio Equipment, Women's Apparel, Water Sports, Indoor/Outdoor Games, and Men's Footwear. The rest contribute very little to both profit and sales.

<img width="2030" height="1582" alt="Logistics   ABC Analysis" src="https://github.com/user-attachments/assets/ede786d7-a5ed-4f07-808c-12effa9e1f3d" />


## Recommendations

1. **Adjust First Class SLA from 1-day to 2-day delivery.** The 0% on-time rate is caused by an unrealistic promise, not poor execution. Simply updating the commitment to match actual capacity would fix this immediately at no extra cost.

2. **Investigate the Second Class fulfilment process.** The wide delay range (1–4 days) and consistently low on-time rate across all regions suggest a systemic issue in how Second Class orders are handled. A process audit is recommended.

3. **Prioritise logistics resources for Class A categories.** These 8 categories drive 85% of profit — ensuring reliable delivery for them should come first when allocating improvement efforts.


- ABC threshold was set at 85% instead of the standard 80%, based on observed profit distribution.
- Delivery performance relies on scheduled vs. actual days in the dataset; external factors like weather or carrier disruptions are not captured.
