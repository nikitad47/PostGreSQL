create table table2(
	add_date date,
	col1 int,
	col2 int,
	col3 int,
	col4 int,
	col5 int
)

insert into table2(add_date,col1,col2,col3,col4,col5) values
('2020-01-01',null,7,8,9,10),
('2020-01-02',11,12,13,14,15),
('2020-01-03',16,17,18,19,20)

select * from table2
	
select * from table2
	coalesce(t1.add_date,t2.add_date) as "add_date",
	coalesce(t1.col1,t2.col1) as "col1",
	coalesce(t1.col2,t2.col2) as "col1",
	coalesce(t1.col3,t2.col3) as "col1",
	t2.col4,
	t2.col5
from table1 t1 full outer join table2 t2 on (t1.add_date=t2.add_date)

select add_date from table1
union all
select add_date from table2