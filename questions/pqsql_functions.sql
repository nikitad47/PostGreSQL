create or replace function fn_api_products_max_price()
returns bigint as
$$
	begin
		return max(unit_price)
		from products;
	end;
$$
language plpgsql

select fn_api_products_max_price()

-- VAIRABLE DECLARATION
do
$$
declare
	mynum integer:=1;
	first_name varchar(100):='Nikita'; 
	hire_date date:='2001-07-04';
	start_time timestamp:= now();
	emptyvar integer;
begin
	raise notice 'Variables % % was born on % and today is % %',
	mynum,
	first_name, 
	hire_date ,
	start_time,
	emptyvar;
end;
$$

create or replace function fn_my_sum(integer default 2,integer default 2)
returns integer as
$$
	declare
		res integer;
		x alias for $1;
		y alias for $2;
	begin
		res = x + y;
		return res;
	end;
$$
language plpgsql

select fn_my_sum() default, fn_my_sum(5,5) assigned


do
$$
	declare
		product_title products.product_name%Type;
	begin
		select product_name
		from products
		into product_title
		where product_id=1;
		
		raise notice 'Product Name is %', product_title;
	end;
$$ 
language plpgsql

do
$$
	declare
		row_product record;
	begin
		select *
		from products
		into row_product
		where product_id=1;
		
		raise notice 'Product is %', row_product;
		raise notice 'Product Name is %', row_product.product_name;
	end;
$$ 
language plpgsql


-- IN OUT INOUT
create or replace function fn_my_sum_inout(in x integer,in y integer, out z integer) as
$$
begin
	z = x + y;
end;
$$
language plpgsql

select fn_my_sum_inout(4,4)

create or replace function fn_my_sum_mul_inout(in x integer,in y integer, out s integer,out m integer) as
$$
begin
	s = x + y; 
	m = x * y;
end;
$$
language plpgsql

select fn_my_sum_mul_inout(4,4)


create or replace function fn_api_latest_orders_return_query()
returns setof orders as
$$
begin
	return query
	select *
	from orders
	order by order_date desc
	limit 10;
end;
$$
language plpgsql

select (fn_api_latest_orders_return_query()).*


-- CONTROL STRUCTURES
-- IF ELSE
create or replace function fn_if_else_product(price real)
returns text as
$$
begin
	if price > 50 then
		return 'High';
	elsif price > 25 then
		return 'Medium';
	else
		return 'Sweet Spot';
	end if;
end;
$$
language plpgsql

select fn_if_else_product(unit_price),* 
from products
order by 1


-- CASE
create or replace function fn_my_check_value(x integer default 0)
returns text as
$$
begin
	case x
		when 10 then
			return 'Value = 10';
		when 20 then
			return 'Value = 20';
		else
			return 'Value not found';
	end case;
end;
$$
language plpgsql

select fn_my_check_value(20)

do
$$
	declare
		total_amount numeric;
		order_type varchar(50);
	begin
		select
			sum((unit_price * quantity) - discount) into total_amount
		from order_details
		where order_id = '10248';

		if found then
			case
				when total_amount > 200 then
					order_type = 'Platinum';
				when total_amount > 100 then
					order_type = 'Gold';
				else
					order_type = 'Silver';
			end case;
			raise notice 'Order Amount % , Order Type %', total_amount,order_type;
		else
		raise notice 'Not Found';
		end if;
	end;
$$
language plpgsql


-- LOOPS
do
$$
	declare
		c integer = 0;
	begin
	loop
		raise notice '%', c;
		c=c+1;
		exit when 
			c=5;
	end loop;
	end;
$$
language plpgsql


-- FOR LOOPS
do
$$
begin
	for c in 1..10 -- for c in reverse 10..1
	loop
		raise notice 'Counter : %', c;
	end loop;
end;
$$
language plpgsql

do
$$
begin
	for c in reverse 10..1
	loop
		raise notice 'Counter : %', c;
	end loop;
end;
$$
language plpgsql

do
$$
begin
	for c in 2..10 by 2
	loop 
		raise notice 'Counter : %', c;
	end loop;
end;
$$
language plpgsql

do
$$
	declare
		c int = 0;
	begin
		loop
			c= c+1;
		exit when c>20;
		continue when mod(c,2) = 0; --/1
		raise notice '%', c;
		end loop;
	end;
$$
language plpgsql

--array foreach
do
$$
	declare
		arr int[]= array[1,2,3];
		var int;
	begin
		foreach var in array arr
		loop
			raise notice '%', var;
		end loop;
	end;
$$
language plpgsql

--WHILE
create or replace function fn_while_sum_all(x int default 3)
returns numeric as
$$
declare
	c int=1;
	s int=0;
begin
	while c<=x
	loop
		s = s+c;
		c= c+1;
	end loop;
	return s;
end;
$$
language plpgsql

select fn_while_sum_all()
select fn_while_sum_all(5)


-- RETURN QUERY
create or replace function fn_api_latest_orders_return_query()
returns setof orders as
$$
begin
	return query			
	select *
	from orders
	order by order_date desc
	limit 10;
end;
$$
language plpgsql

select fn_api_latest_orders_return_query()


--RETURNS TABLE
create or replace function fn_api_products_by_name(pattern varchar)
returns table (productname varchar, unitprice real) as
$$
	begin
		return query
			select
				product_name,
				unit_price
			from products
			where product_name like pattern;
	end;
$$
language plpgsql

select (fn_api_products_by_name('B%')).*


-- RETURN NEXT
create or replace function fn_get_all_orders_greater_than(unitprice real default 10)
returns setof order_details as
$$
	declare
		r record;
	begin
		for r in
			select * from order_details
			where unit_price > unitprice
		loop
			return next r;
		end loop;
		return;
	end;
$$
language plpgsql

select * from fn_get_all_orders_greater_than()
select * from fn_get_all_orders_greater_than(100)
select * from fn_get_all_orders_greater_than(210.8)


--EXCEPTIONS
--errorcodes : https://www.postgresql.org/docs/8.4/errcodes-appendix.htm