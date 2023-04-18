create table t_accounts(
	recid serial primary key,
	name varchar not null,
	balance dec(15,2) not null
)

insert into t_accounts(name, balance) values
('Nikita',100),
('Nikki',100)

select * from t_accounts

create or replace procedure pr_money_transfer(
	sender int,
	reciever int,
	amount dec
) as
$$
	begin
		update t_accounts
		set balance = balance - amount
		where recid = sender;
		
		update t_accounts
		set balance = balance + amount
		where recid = reciever;
		
		commit;
	end;
$$
language plpgsql

call pr_money_transfer(2,1,50)

create or replace procedure pr_orders_count(inout total_count integer default 0) as
$$
	begin
		select count(*)
		into total_count
		from orders;
	end;
$$
language plpgsql

begin;
	call pr_orders_count(20);
commit

create or replace procedure pr_begin() as
$$
begin
	begin transaction;
	raise notice 'transaction begin in sp';
end;
$$
language plpgsql

begin;
	create table t1 ( x int);
commit;

begin;
	drop table t1
commit;

select * from t1
rollback

create or replace procedure pr_create_table() as
$$
begin
	create table t8(x int);
	drop table t8;
	create table t8(x int);
end;
$$
language plpgsql

call pr_create_table()
select * from t8

begin transaction
	create  table t7(x int);
	insert into t7 values(1)
commit
rollback
select * from t
drop table t
select * from pg_temp_12
select * from information_schema.schemata