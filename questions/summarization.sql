create table courses(
	course_id serial primary key,
	course_name varchar(100) not null,
	course_level varchar(100) not null,
	sold_units int not null
)

select * from courses

insert into courses (course_name,course_level,sold_units) values
('Machine Learning with Python','Premium',100),
('Data Science Bootcamp','Premium',50),
('Introduction to Python','Basic',200),
('Understanding MongoDB','Premium',100),
('Algorithm Design in Python','Premium',200)

select * from courses
order by course_level, sold_units

select
	course_level,
	sum(sold_units) "total sold"
from courses
group by 1

select
	course_level,
	course_name,
	sum(sold_units) "total sold"
from courses
group by 1,2
order by 1,2

-- ROLLUP
select
	course_level,
	course_name,
	sum(sold_units) "total sold"
from courses
group by rollup(1,2)
order by 1,2

-- PARTIAL ROLLUP
select
	course_level,
	course_name,
	sum(sold_units) "total sold"
from courses
group by 1,rollup(2)
order by 1,2

create table inventory(
	inventory_id serial primary key,
	category varchar(100) not null,
	sub_category varchar(100) not null,
	product varchar(100) not null,
	quantity int
)

select * from inventory

insert into inventory (category,sub_category,product,quantity) values
('Furniture','Chair','Black',10),
('Furniture','Chair','Brown',10),
('Furniture','Desk','Blue',10),
('Equipment','Computer','Mac',5),
('Equipment','Computer','PC',5),
('Equipment','Monitor','Dell',10)

select 
	category,
	sub_category,
	sum(quantity) "Quantity"
from inventory
group by rollup(1,2)
order by 1,2

select 
	category,
	sub_category,
	sum(quantity) "Quantity",
	grouping(category) "Category grouping",
	grouping(sub_category) "subcategory grouping"
from inventory
group by rollup(1,2)
order by 1,2

select 
	category,
	sub_category,
	sum(quantity) as "Quantity",
	case
		when grouping(category) = 1 then 'Grand Total' else ' '
	end as "subtotal"
from inventory
group by rollup(category,sub_category)
order by 1,2 nulls last

select 
	CASE
		when grouping(category) = 1 then 'grand total'
		when grouping(sub_category) = 1 then 'subtotal -> '
		else
			category
	end as cat,
	sub_category sub_cat,
	sum(quantity) as "quantity"
from inventory
group by rollup(category,sub_category)
order by category, sub_category nulls last