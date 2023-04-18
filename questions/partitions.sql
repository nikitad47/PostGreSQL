create table master(
	pk serial primary key,
	tag text,
	parent integer
)

create table master_child() inherits (master)

select * from master

select * from master_child

alter table master_child 
add constraint master_pk primary key(pk)

insert into master(pk,tag,parent) values
(1,'pen',0)

insert into master_child(pk,tag,parent) values
(2,'pencil',0)

select * from only master

select * from only master_child

update master
set tag='monitor'
where pk=2

delete from master
where pk=2

drop table master cascade

--RANGE
create table employees_range(
	id bigserial,
	birth_date date not null,
	country_code varchar(2) not null
) partition by range (birth_date)

select * from employees_range

create table employees_range_y2000 partition of employees_range
	for values from ('2000-01-01') to ('2001-01-01')
	
create table employees_range_y2001 partition of employees_range
	for values from ('2001-01-01') to ('2002-01-01')
	
select * from  employees_range_y2000

select * from  employees_range_y2001

select * from eMployees_range

select * from only employees_range

insert into employees_range (birth_date,country_code) values
('2000-01-01','US'),
('2000-01-02','US'),
('2000-12-31','US'),
('2001-01-01','US')

update employees_range
set birth_date = '2001-10-10'
where id =1

delete from employees_range
where id = 1

-- LIST
create table employees_list(
	id bigserial,
	birth_date date not null,
	country_code varchar(2) not null
) partition by list (country_code)

create table employees_list_us partition of employees_list
for values in ('US')

create table employees_list_ue partition of employees_list
for values in ('UK','DE','IT','FR','ES')

select * from employees_list

select * from employees_list_us

select * from employees_list_ue

select * from only employees_list

select * from only employees_list_us

select * from only employees_list_ue

insert into employees_list (id,birth_date,country_code) values
(1,'2000-01-01','US'),
(2,'2000-01-02','US'),
(3,'2000-12-31','UK'),
(4,'2001-01-01','DE')

-- HASH
create table employees_hash(
	id bigserial,
	birth_date date not null,
	country_code varchar(2) not null
) partition by hash (id)

create table employees_hash_1 partition of employees_hash
	for values with (modulus 3, remainder 0)

create table employees_hash_2 partition of employees_hash
	for values with (modulus 3, remainder 1)
	
create table employees_hash_3 partition of employees_hash
	for values with (modulus 3, remainder 2)

select * from only employees_hash
select * from only employees_hash_1
select * from only employees_hash_2
select * from only employees_hash_3

select * from employees_hash
select * from employees_hash_1
select * from employees_hash_2
select * from employees_hash_3

insert into employees_hash (id,birth_date,country_code) values
(1,'2000-01-01','US'),
(2,'2000-01-02','US'),
(3,'2000-12-31','UK')


--DEFAULT
insert into employees_list (id,birth_date,country_code) values
(1,'2001-01-01','JP')

create table employees_list_default partition of employees_list default

select * from employees_list where country_code = 'JP'

--MultiLevel Partitioning
create table employees_master(
	id bigserial,
	birth_date date not null,
	country_code varchar(2) not null
) partition by list (country_code)

create table employees_master_us partition of employees_master
	for values in ('US')

create table employees_master_ue partition of employees_master
	for values in ('UK','DE','IT','FR','ES')
	partition by hash(id)
	
create table employees_master_ue_1 partition of employees_master_ue
	for values with (modulus 3, remainder 0);

create table employees_master_ue_2 partition of employees_master_ue
	for values with (modulus 3, remainder 1);
	 
create table employees_master_ue_3 partition of employees_master_ue
	for values with (modulus 3, remainder 2);
	
insert into employees_master (id,birth_date,country_code) values
(1,'2000-01-01','US'),
(2,'2000-01-02','US'),
(3,'2000-12-31','UK'),
(4,'2001-01-01','DE')

select * from employees_master
select * from employees_master_us
select * from employees_master_ue
select * from only employees_master_ue
select * from employees_master_ue_1
select * from employees_master_ue_2
select * from employees_master_ue_3

--DETACH
create table employees_list_sp partition of employees_list
	for values in ('SP')
	
insert into employees_list (id,birth_date,country_code) values
(10,'2020-01-01','SP')

select * from employees_list
select * from employees_list_sp	

alter table employees_list detach partition employees_list_sp

--ATTACH
create table tab1 (a int, b int) partition by range(a)

create table tab1p1 partition of tab1 for values from (0) to (100)
 	
insert into tab1 (a,b) values(1,1)
insert into tab1 (a,b) values(150,150)

select * from tab1
select * from tab1p1
select * from tab1p2

rollback
begin transaction
	alter table tab1 detach partition tab1p1
	alter table tab1 attach partition tab1p1 for values from (0) to (200)
commit transaction

--INDEXES
create unique index idx_employee_list_id on employees_list(id) -- doesn't work

create unique index idx_employee_list_id on employees_list(id,country_code)
delete from employees_list where id=4

--PRUNING
show enable_partition_pruning

select * from employees_list where country_code='US'

set enable_partition_pruning=on