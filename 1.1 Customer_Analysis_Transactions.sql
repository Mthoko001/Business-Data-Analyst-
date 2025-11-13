-- 1. Gathering Customer details and their transaction details--
-- creating a cte for best readability--
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
s.sales_amount
from dim_customers c
-- joining tables since they are related--
left join 
fact_sales s
on c.customer_key = s.customer_key
)
-- here calling the above temporary  query( cte)--
select * from temporary_query