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


