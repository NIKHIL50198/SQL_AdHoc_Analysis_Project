🛠️ Consumer Goods Analysis

## Live Dashboard:_[Consumer_Goods_Ad_Hoc_insights](https://app.powerbi.com/links/WdiAqACYdl?ctid=c6e549b3-5f45-4032-aae9-d4244dc5b2c4&pbi_source=linkShare)




# Problem Statement  
Atliq Hardwares, a leading computer hardware manufacturer based in India with a global presence, is seeking to enhance its data analytics capabilities. The management has observed a lack of sufficient insights for making swift, data-driven decisions. To address this, they plan to expand their data analytics team by recruiting several junior data analysts. Tony Sharma, the Data Analytics Director, aims to find candidates proficient in both technical and interpersonal skills. To evaluate these abilities, he has organized a SQL challenge.

## 1. ASK  
Director: Mr. Tony Sharma 

### Questions:  
- Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
- What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields : unique_products_2020, unique_products_2021 & percentage_chg.
- Provide a report with all the unique product counts for each segment and sort them in descending order of product counts? The final output contains 2 fields: segment & product_count.
- Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields: segment, product_count_2020, product_count_2021 & difference.
- Get the products that have the highest and lowest manufacturing costs? The final output should contain these fields: product_code, product & manufacturing_cost.
- Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields: customer_code, customer & average_discount_percentage.
- Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: Month, Year & Gross sales Amount.
- In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity, Quarter & total_sold_quantity.
- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields: channel, gross_sales_mln & percentage.
- Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields: division, product_code, product, total_sold_quantity & rank_order.


## 2. PREPARE  
### Data Storage:
[Resume Project Challenge 04] The public dataset is completely available on the Code basis website platform where it stores and consolidates all available datasets for analysis. The specific individual datasets at hand can be obtained at this link below: https://codebasics.io/challenge/codebasics-resume-project-challenge  

### Data Organized:
The dataset is taken from the AtliQ. Thanks to the AtliQ for providing datasets for public access which is a great learning asset - feel free to explore them here. This dataset contains only gdb023' (atliq_hardware_db) database and 1 text file (meta_data)


## 3. PROCESS  
### Tools Used:
1. MySQL
2. Power BI

### Data Used:
dim_customers, dim_product, fact_gross_price, fact_manufacturing_cost, fact_pre_invoice_deductions, fact_sales_monthly  


### Data Cleaning & Transformation:
- In PowerBI, Replace Newzealand with New Zealand.
- Performing data validation of all the datasets.

## 4. ANALYZE  
Data Analyzing  
MySQL was used to analyze data.  

-- KPI’s REQUIREMENT --  

```-- #Q1
select market 
from dim_customer 
where customer = "Atliq Exclusive" AND region = "APAC";

-- #Q2
WITH unique_products_20 AS (
  SELECT count(distinct product_code) as unique_products_2020 
  FROM FACT_SALES_MONTHLY 
  where fiscal_year=2020
),
unique_products_21 as (
  select count(distinct product_code) as unique_products_2021
  from fact_sales_monthly
  where fiscal_year=2021
)
select 
  t1.unique_products_2020,
  t2.unique_products_2021,
  round((t2.unique_products_2021 - t1.unique_products_2020) * 100 / t1.unique_products_2020,2) as percentage_chg
from 
  unique_products_20 t1, 
  unique_products_21 t2;

-- #Q3
select 
  segment,
  count(distinct(product_code)) as product_count
from dim_product
group by segment 
order by product_count desc;

-- #Q4
with cte1 as (
  select p.segment, count(distinct sm.product_code) as product_count_2020
  from dim_product p
  join fact_sales_monthly sm on p.product_code = sm.product_code
  where sm.fiscal_year=2020
  group by p.segment
),
cte2 as (
  select p.segment as segment_, count(distinct sm.product_code) as product_count_2021
  from dim_product p
  join fact_sales_monthly sm on p.product_code = sm.product_code
  where sm.fiscal_year=2021
  group by p.segment
),
cte3 as (
  select *, (product_count_2021 - product_count_2020) as difference
  from cte1 c1
  join cte2 c2 on c1.segment = c2.segment_
)
select segment, product_count_2020, product_count_2021, difference
from cte3
order by difference desc;

-- #Q5
select 
  p.product_code, p.product, mc.manufacturing_cost
from dim_product p
join fact_manufacturing_cost mc on p.product_code = mc.product_code
where mc.manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
   or mc.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost)
order by manufacturing_cost desc;

-- #Q6
select 
  pid.customer_code, dc.customer, round(avg(pid.pre_invoice_discount_pct),4) as average_discount_percentage
from fact_pre_invoice_deductions pid
join dim_customer dc on pid.customer_code = dc.customer_code
where fiscal_year=2021 and market='India'
group by customer_code, customer
order by average_discount_percentage desc limit 5;

-- #Q7
select 
  monthname(sm.date) as month_,
  sm.fiscal_year,
  round(sum((gp.gross_price * sm.sold_quantity)),2) as Gross_sales_amount
from fact_sales_monthly sm
join fact_gross_price gp on sm.product_code = gp.product_code and sm.fiscal_year = gp.fiscal_year
join dim_customer c on c.customer_code = sm.customer_code
where customer = 'Atliq Exclusive'
group by month_, sm.fiscal_year
order by sm.date asc;

-- #Q8
with cte as (
  select month(date) as m_, sum(sold_quantity) as tsq
  from fact_sales_monthly
  where fiscal_year = 2020
  group by m_
)
select 
  case 
    when m_ in (9,10,11) then "q1"
    when m_ in (12,1,2) then "q2"
    when m_ in (3,4,5) then "q3"
    else "q4" 
  end as quarters, 
  sum(tsq) as total_sold_quantity
from cte
group by quarters
order by total_sold_quantity desc;

-- #Q9
with cte as (
  select 
    c.channel, 
    round(sum((gross_price * sm.sold_quantity)/1000000),2) as gross_sales_mln
  from fact_sales_monthly sm
  join fact_gross_price gp on sm.product_code = gp.product_code and sm.fiscal_year = gp.fiscal_year
  join dim_customer c on c.customer_code = sm.customer_code
  where sm.fiscal_year=2021 
  group by channel
)
select 
  channel,
  gross_sales_mln,
  round((gross_sales_mln / sum(gross_sales_mln) over())*100,2) as percentage
from cte
order by gross_sales_mln desc;

-- #Q10
with cte as (
  select sm.product_code, p.product,
         p.division, sum(sm.sold_quantity) as total_sold_quantity, sm.fiscal_year,
         rank() over(partition by p.division order by sum(sm.sold_quantity) desc) as rank_order
  from fact_sales_monthly sm
  join dim_product p on p.product_code = sm.product_code
  where fiscal_year=2021
  group by p.division, sm.product_code, p.product
)
select 
  division, product_code, product, total_sold_quantity, rank_order
from cte
where rank_order in (1,2,3);
```

## 5. SHARE	
![Screenshot (105)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/Screenshot%20(566).png
)
![Screenshot (106)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0003.jpg
)
![Screenshot (107)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0004.jpg)

![Screenshot (108)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0005.jpg)

![Screenshot (109)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0006.jpg)

![Screenshot (110)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0007.jpg)

![Screenshot (111)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0008.jpg)

![Screenshot (112)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0009.jpg)

![Screenshot (113)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0010.jpg)


![Screenshot (114)](https://github.com/NIKHIL50198/SQL_AdHoc_Analysis_Project/blob/b7720d9ace5b6c1d082d70741ab4f81886548f85/images/adhoc%20sql_power%20bi_project_final_complete_page-0011.jpg)




## 6. ACT
### Insights:
- AtliQ Exclusive operates its business in eight countries within the APAC region are as follows: India, Indonesia, Japan, Philiphines, South Korea, Australia, New Zealand, Bangladesh.
- In the fiscal year 2020, we had a total of 245 products, which increased to 334 in the fiscal year 2021, marking a 36% growth.
- Notebooks, Accessories, and Peripherals are the three top segments.
- The Accessories segment had the most unique products in 2021 compared to 2020.
- The AQ HOME Allin1 Gen 2 has the highest manufacturing cost, while the AQ Master wired x1 MS has the lowest manufacturing cost.
- Flipkart, Viveks, Ezone, Croma, and Amazon offered the highest average discount percentages in the Indian market for the fiscal year 2021.
- In 2020, March was the lowest performing month, while october saw the highest performance. For 2021, August was the lowest performing month, with November again being the highest.
- The first quarter of 2020 (September, October, November) saw the highest number of products sold.
- The retailer channel significantly boosted gross sales in the fiscal year 2021, contributing 73.23%.
- The top-selling products in the fiscal year 2021 were as follows: N&S Division: AQ Pen Drive 2 in 1, AQ Pen Drive DRC, P&A Division: AQ Gamers MS, AQ Maxima MS, PC Division: AQ Digit, AQ Velocity


### Recommendations:
- Maximize Online Discounts: Work with Flipkart, Viveks, Ezone, Croma, and Amazon for exclusive online deals.
- Boost March and September: Implement special offers to improve sales during these low months.
- Cost Reduction: Reduce manufacturing costs for the AQ HOME Allin1 Gen 2.
- Replicate Q1 Success: Analyze and replicate strategies that boosted first-quarter sales in 2020.

Thank you for reading and evaluating my report :)        
[Connect with me on LinkedIn](https://www.linkedin.com/in/nikhil-dhasmana-3b2b90137/)

