select * from orders
where ship_country = 'USA'
group by 1

select 
	order_id,
	product_id,
	unit_price,
	quantity,
	discount,
	((unit_price*quantity)-discount) "Total amount"
from order_details

select
	min(order_date),
	max(order_date)
from orders

select 
	c.category_name,
	count(*) "total products"
from products p
inner join categories c using(category_id)
group by 1

select * from products
where units_in_stock<= reorder_level

select 
	ship_country,
	avg(freight)
from orders
group by 1
order by 2 desc
limit 5

select 
	ship_country,
	order_date,
	avg(freight)
from orders
where order_date between '1997-01-01' and '1997-12-31'
group by 1, 2
order by 2 desc
limit 5


select *
from customers c
left join orders o on o.customer_id=c.customer_id
where o.customer_id is null

select
	c.customer_id,
	c.company_name,
	sum((od.unit_price * od.quantity) - od. discount)
from customers c
join orders o using (customer_id)
join order_details od using (order_id)
group by 1, 2
order by 3 desc
limit 10

select 
	order_id,
	count(*)
from order_details
group by 1

select *
from orders
where shipped_date>required_date

with late_orders as
(
	select
		employee_id,
		count(*) "total_late_orders"
	from orders
	where shipped_date>required_date
	group by 1
),
all_orders as
(
	select
		employee_id,
		count(*) "total_orders"
	from orders
	group by 1
)
select 
	e.employee_id,
	e.first_name,
	a.total_orders,
	l.total_late_orders
from employees e
join all_orders a using (employee_id)
join late_orders l using (employee_id)
order by l.total_late_orders desc

select
	distinct country
from customers
union
select
	distinct country
from customers
order by 1