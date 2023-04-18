create index idx_orders_order_date on orders(order_date)

explain select order_id from orders where order_id = 1

create index idx_orders_customer_id_order_id on orders (customer_id,order_id)

create unique index idx_u_employees_employee_id on employees(employee_id)

create unique index idx_u_orders_order_id_customer_id on orders (order_id,customer_id)

create unique index idx_u_employees_employee_id_hire_date on employees(employee_id,hire_date)

select * from pg_indexes where tablename='employees'

select pg_size_pretty(pg_indexes_size('employees'))

select count(*) from pg_indexes where tablename='employees'

select * from pg_stat_all_indexes where relname='employees'

explain (analyze) select * from pg_am
	
explain analyze select order_id from orders where order_id=1

explain (format json) select orders.customer_id from orders join customers on orders.customer_id=customers.customer_id