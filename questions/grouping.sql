select
	case 
		when grouping(category)= 1 then  'Grand Total'
		when grouping(sub_category) = 1 then ''
		else
			coalesce(category,'')
	end as "cat",
	case
		when (grouping(category)= 1 and grouping(sub_category) = 1) then ''
		when grouping(sub_category) = 0 then sub_category
		when grouping(sub_category) = 1 then
			category || ' -> ' || 'Sub Total' 
	end as "sub_cat",
	sum(quantity) as "Quantity"
from inventory
group by 
	rollup(category,sub_category)
order by category, sub_category

select *,dense_rank() over (partition by category order by sub_category) 
from inventory

create table inventory (
	inventory_id serial primary key,
	category varchar(100),
	sub_category varchar(100),
	product varchar(100),
	quantity integer
)

insert into inventory (category,sub_category,product,quantity) values
('Furniture','Chair','Black',10),
('Furniture','Chair','Brown',10),
('Furniture','Desk','Blue',10),
('Equipment','Computer','Mac',5),
('Equipment','Computer','PC',5),
('Equipment','Monitor','Dell',10),
('Z','Something','yellow',10);

select * from inventory