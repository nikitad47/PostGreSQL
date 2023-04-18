--Which shipping company has the second highest quantity for shipment
select * from order_details order by quantity desc

select distinct(ship_via) from orders

select 
	s.company_name,
	sum(od.quantity) total_quantity
from shippers s
join orders o on s.shipper_id=o.ship_via
join order_details od using(order_id)
group by 1
order by 2 desc
limit 1
offset 1

--The manager on employees wants to know which are the products that have been ordered but are not in stock for all employees reporting into him/her
select 
	employee_id, 
	concat_ws(' ',first_name,last_name) 
from employees 
where employee_id in
	(select 
	 	reports_to 
	 from employees 
	 where employee_id in
		(select 
			distinct(o.employee_id) 
		from orders o
		join order_details od using(order_id)
		where od.product_id in(
				select
					product_id
				from products
				where units_in_stock=0
		)
	)
)

select e1.employee_id,e1.first_name, 
from employees e1
join employees e2 using(employee_id) where 


--Names of the shipping companies that do not have any orders to ship.
select company_name
from shippers
where shipper_id not in(
	select ship_via
	from orders
)


--Cover with Check Option


--Get all the customers where the total quantity of products is greater than average of the region that the customer belong to
with cte as(
	select c.region, avg(od.quantity) avg_qty
	from customers c
	join orders o using(customer_id)
	join order_details od using(order_id)
	group by 1
),
cte2 as(
	SELECT c.customer_id, c.region, sum(od.quantity) sum_qty
	from customers c
	join orders o using(customer_id)
	join order_details od using(order_id)
	group by 1,2
)
select 
	* 
from cte
join cte2 using(region)
where sum_qty > avg_qty