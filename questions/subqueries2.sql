-- ANY
select * from order_details;

select
	*
from customers
where customer_id = any (
	select
		customer_id
	from orders
	inner join order_details using(order_id)
	where quantity > 20
)

-- ALL
select
	* 
from products p
inner join order_details od using(product_id)
where ((od.unit_price * od.quantity) - od.discount) < all(
	select
		avg((unit_price*quantity)-discount)
	from order_details
	group by product_id
)

-- EXISTS
select
	*
from suppliers
where exists(
	select
		*
	from products
	where unit_price > 100
	and products.supplier_id=suppliers.supplier_id
	order by unit_price
)