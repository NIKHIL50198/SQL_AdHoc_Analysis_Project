
#Q1
select market from dim_customer where customer = "Atliq Exclusive" AND region = "APAC";

 
 #Q2
 WITH unique_products_20 AS (
 SELECT count(distinct product_code) as unique_products_2020 
 FROM FACT_SALES_MONTHLY 
 where fiscal_year= 2020
 ),
 unique_products_21 as (
 select count(distinct product_code) as unique_products_2021
 from fact_sales_monthly
 where fiscal_year= 2021
 )
 select 
 t1.unique_products_2020,
 t2.unique_products_2021,
 round((t2.unique_products_2021- t1.unique_products_2020)*100/ t1.unique_products_2020,2) as percentage_chg
 from 
 unique_products_20 t1,
 unique_products_21 t2;
 
 
 #Q3
 select 
  segment,
 count(distinct(product_code))as product_count
 from dim_product
 group by segment 
 order by product_count  desc
 
 
 #Q4
 with cte1 as ( 
 select p.segment, count(distinct sm.product_code) as product_count_2020
 from dim_product p
 join fact_sales_monthly sm
 on p.product_code= sm.product_code
 where sm.fiscal_year= 2020
 group by  p.segment),
  cte2 as ( 
 select p.segment as segment_, count(distinct sm.product_code) as product_count_2021
 from dim_product p 
join fact_sales_monthly sm
 on p.product_code = sm.product_code
 where sm.fiscal_year= 2021
 group by  p.segment),
  cte3 as (select *, (product_count_2021- product_count_2020) as difference
 from cte1 c1
 join cte2 c2
 on c1.segment= c2.segment_
 )
 select segment, product_count_2020, product_count_2021, difference
 from cte3
 order by difference desc
 
 
 #Q5
select 
 p.product_code, p.product, mc.manufacturing_cost
 from dim_product p
 join fact_manufacturing_cost mc
 on p.product_code= mc.product_code
 where mc.manufacturing_cost= (select max(manufacturing_cost) from fact_manufacturing_cost)
 or mc.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost)
 order by manufacturing_cost desc;
 
 
 #Q6
 select 
 pid.customer_code, dc.customer,Round(AVG( pid.pre_invoice_discount_pct),4) as average_discount_percentage
 from fact_pre_invoice_deductions pid
 join dim_customer dc
 on pid.customer_code= dc.customer_code
 where fiscal_year= 2021 and market='India'
 group by customer_code, customer
 order by average_discount_percentage desc limit 5
 
 
 #Q7
  select
 MONTHNAME(sm.date) as month_,
 sm.fiscal_year,
 round(sum((gp.gross_price*sm.sold_quantity)),2)as Gross_sales_amount
 from  fact_sales_monthly sm
 join fact_gross_price gp
 on 
 sm.product_code=gp.product_code and
 sm.fiscal_year=gp.fiscal_year
 join dim_customer c
 on c.customer_code= sm.customer_code
 where customer= 'Atliq Exclusive'
 group by month_, sm.fiscal_year
 order by sm.date asc;
 
 
 #Q8
 with cte as (select 
 month(date) as m_, sum(sold_quantity) as tsq
 from fact_sales_monthly 
 where fiscal_year = 2020
 group by m_)
 select 
 CASE
 WHEN m_ IN(9,10,11) THEN "q1"
  WHEN m_ IN(12,1,2) THEN "q2"
 WHEN m_ IN(3,4,5) THEN "q3"
 ELSE "q4" 
 END as quarters , sum(tsq) as total_sold_quantity
 from cte
 group by quarters
 order by total_sold_quantity desc;
 
 
 #Q9
  with cte as (select 
 c.channel, 
 round(sum((gross_price*sm.sold_quantity)/1000000),2) as gross_sales_mln
 from  fact_sales_monthly sm
 join fact_gross_price gp
 on sm.product_code=gp.product_code and
 sm.fiscal_year= gp.fiscal_year
 join dim_customer c
 on c.customer_code= sm.customer_code
 where sm.fiscal_year= 2021 
 group by channel)
 select 
 channel,gross_sales_mln, 
 ROUND((gross_sales_mln/sum(gross_sales_mln) over())*100,2) as percentage
 from cte
order by gross_sales_mln  desc;


#Q10
with cte as ( select sm.product_code,p.product,
p.division, sum(sm.sold_quantity) as total_sold_quantity, sm.fiscal_year, rank() over(partition by p.division 
order by sum(sm.sold_quantity)desc)as rank_order
from fact_sales_monthly sm
join dim_product p
on p.product_code= sm.product_code
where fiscal_year= 2021
group by p.division,sm.product_code,p.product   )
select 
division, product_code, product, total_sold_quantity,
rank_order
from cte 
where rank_order  in(1,2,3);

 
 
