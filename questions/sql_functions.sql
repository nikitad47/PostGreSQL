create or replace function fn_sum(int,int) 
returns int as 
$$
	select $1 + $2
$$
language sql

create or replace function fn_sum2()
returns int as 
$body$
	select 1 + 2
$body$
language sql

select fn_sum(5,5)

select fn_sum2()


-- returning nothing
create or replace function fn_employees_update_country()
returns void as
$$
	update employees
	set country	= 'N/A'
	where country is NULL
$$
language sql

select fn_employees_update_country()

select * from employees

-- returning single value
create or replace function fn_products_max_price()
returns real as
$$
	select
		max(unit_price)
	from products
$$
language sql

drop function fn_products_max_price()

select fn_products_max_price()

create or replace function fn_api_get_total_customers()
returns bigint as
$$
	select count(*) from customers
$$
language sql

select fn_api_get_total_customers()

create or replace function fn_api_get_total_products()
returns bigint as
$$
	select count(*) from products
$$
language sql

select fn_api_get_total_products()

create or replace function fn_api_get_total_orders()
returns bigint as
$$
	select count(*) from orders
$$
language sql

select fn_api_get_total_orders()

create or replace function fn_api_get_total_customers_empty_fax()
returns bigint as
$$
	select count(*) 
	from customers
	where fax is null
$$
language sql

select fn_api_get_total_customers_empty_fax()

create or replace function fn_api_get_total_customers_empty_region()
returns bigint as
$$
	select count(*) 
	from customers
	where region is null
$$
language sql

select fn_api_get_total_customers_empty_region()


-- Parameterized
create or replace function fn_mid(string varchar, starting_point integer)
returns varchar as
$$
	select substring(string,starting_point)
$$
language sql

select fn_mid('Nikita Dara','8')

create or replace function fn_api_get_total_customers_by_city(p_city varchar)
returns bigint as
$$
	select count(*)
	from customers
	where city=p_city
$$
language sql

select fn_api_get_total_customers_by_city('Paris')


create or replace function fn_api_get_total_customers_by_country(p_country varchar)
returns bigint as
$$
	select count(*)
	from customers
	where country=p_country
$$
language sql

select fn_api_get_total_customers_by_country('UK')


create or replace function fn_api_customer_largest_order(p_customer_id bpchar)
returns double precision as
$$
	select
		max(order_amount)
	from(
		select 
			o.order_id,
			sum((unit_price*quantity)-discount) order_amount
		from order_details od
		natural join orders o
		where o.customer_id = p_customer_id
		group by 1
	) as total_amount
$$
language sql

select fn_api_customer_largest_order('ALFKI')


create or replace function fn_api_customer_most_ordered_product(p_customer_id bpchar)
returns varchar as
$$
	select
		product_name
	from products
	where product_id in(
		select 
			product_id
		from(
			select
				product_id,
				sum(quantity) total_quantity
			from order_details od
			natural join orders o
			where o.customer_id = p_customer_id
			group by 1
			order by 2 desc
			limit 1
		) product_order
	)
$$
language sql

select fn_api_customer_most_ordered_product('CACTU')

--composite
create or replace function fn_api_order_latest()
returns orders as
$$
	select *
	from orders
	order by order_date desc, order_id desc
	limit 1
$$
language sql

select fn_api_order_latest()
		
select (fn_api_order_latest()).*

select (fn_api_order_latest()).order_id

select order_id(fn_api_order_latest())


create or replace function fn_api_order_latest_by_date_range(p_from date,p_to date)
returns orders as
$$
	select *
	from orders
	where order_date between p_from and p_to
	order by order_date desc, order_id desc
	limit 1
$$
language sql

select (fn_api_order_latest_by_date_range('1997-01-01','1997-10-10')).*


--multiple rows
create or replace function fn_api_products_total_amount_by(p_amount int)
returns setof products as
$$
	select *
	from products
	where product_id in(
		select product_id
		from (
			select 
				product_id,
				sum((unit_price*quantity)-discount) product_total_sale
			from order_details
			group by 1
			having sum((unit_price*quantity)-discount) > p_amount
		) t1
	)
$$
language sql

select (fn_api_products_total_amount_by('100000')).*


-- table source
create or replace function fn_api_customer_top_orders(p_customer_id bpchar,p_limit integer)
returns table (
	order_id smallint,
	customer_id bpchar,
	product_name varchar,
	unit_price real,
	quantity smallint,
	total_quantity double precision
) as
$$
	select 
		o.order_id,
		o.customer_id,
		p.product_name,
		od.unit_price,
		od.quantity,
		((od.unit_price*od.quantity)-od.discount) total_quantity
	from order_details od
	natural join orders o
	natural join products p
	where o.customer_id = p_customer_id
	order by ((unit_price*quantity)-discount) desc
	limit p_limit
$$
language sql

select (fn_api_customer_top_orders('VINET',2)).*


-- default parameter
create or replace function fn_api_customer_top_orders_default(p_customer_id bpchar,p_limit integer default 2)
returns table (
	order_id smallint,
	customer_id bpchar,
	product_name varchar,
	unit_price real,
	quantity smallint,
	total_quantity double precision
) as
$$
	select 
		o.order_id,
		o.customer_id,
		p.product_name,
		od.unit_price,
		od.quantity,
		((od.unit_price*od.quantity)-od.discount) total_quantity
	from order_details od
	natural join orders o
	natural join products p
	where o.customer_id = p_customer_id
	order by ((unit_price*quantity)-discount) desc
	limit p_limit
$$
language sql

select (fn_api_customer_top_orders_default('VINET',3)).*

create or replace function fn_api_new_price(products,perc_increarse numeric default 107)
returns double precision as
$$
	select $1.unit_price * perc_increarse / 100
$$
language sql

select
	product_id,
	product_name,
	unit_price,
	fn_api_new_price(products.*) new_price
from products