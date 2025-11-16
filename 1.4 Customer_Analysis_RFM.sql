/* 1. Gathering Customer details and their transactions details
creating a cte for best readability*/

with temporary_query as (
select 
c.customer_key,
c.customer_number,
-- combining name and surname--
CONCAT(c.first_name, ' ' , c.last_name) as customer_name, 
-- calculating customer's age--
DATEDIFF(year, c.birthdate, getdate()) as age,
s.product_key,
s.order_number,
s.order_date,
s.sales_amount,
s.quantity
from dim_customers c
-- joining tables since they are related--
left join 
fact_sales s
on c.customer_key = s.customer_key
)
-- here calling the above temporary  query( cte)--
/*with the use of above cte, i am quering the columns
*

2. pulling KPI  [Measure Exlporation] */
,customer_aggregate as(
select 
	customer_key,
	customer_number,
	customer_name,
	age,
	--aggregates total number of orders
	COUNT(distinct order_number) as total_orders,

	SUM(sales_amount ) as total_sales,
	SUM(quantity)as total_quantity,
	-- to count how many total orders the customer made-- 
	COUNT( distinct product_key)as total_product,
	MAX(order_date) as last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) as lifespan
from temporary_query
group by
customer_key,
customer_number,
customer_name,
age
)
-- 3. group customers into  segments based on their spending behavior--
select 
	customer_key,
	customer_number,
	customer_name,
	age,
	--categorizing customers in age group--
	case when age < 20 then 'under 20'
     when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 else '50 and above'
	  end  age_group,
	  
	--categorizing customers in categories--
case
when total_sales > 5000 and lifespan >= 12  then 'VIP'
when total_sales <= 5000 and lifespan >= 12 then 'Regular'
else 'New'
end customer_category,
last_order_date,
--getting recent order amount for each  customer--
DATEDIFF (MONTH,last_order_date,getdate()) as recency,
	total_orders,
	total_sales,
	total_quantity,
	--compute average order value--
case when total_orders = 0 then 0  
else total_sales/total_orders
end avg_order_value,
	lifespan
from customer_aggregate