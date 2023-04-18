-- FEED1
CREATE TABLE feed1
(
	_id serial PRIMARY KEY,
	report_date date not null,
	desk_id text not null ,
	product_id text not null,
	quantity int not null default 0 ,
	amount int not null default 0
)	

drop table feed1

select * from feed1

update feed1
set desk_id = 'd'||desk_id

update feed1
set product_id = '1p'||product_id


--FEED2
create table feed2(
	_id SERIAL PRIMARY KEY,
	transaction_type varchar(4) not null,
	product_id text not null,
	quantity int not null,
	trade_date date not null,
	desk_id text not null
)

select * from feed2

delete from feed2

drop table feed2

update feed2
set desk_id = 'd'||desk_id

update feed2
set product_id = '2p'||product_id

delete from transactions
where product_id like '2p%'

--FEED3
create table feed3(
	_id int primary key,
	trade_date date,
	desk_id text,
	product_id text,
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
);

drop table feed3

select * from feed3

update feed3
set desk_id = 'd'||desk_id

update feed3
set product_id = '3p'||product_id

--PRICES
create table prices (
	product_id text primary key not null,
	price int not null,
	updated_date date not null
)

update prices
set product_id = '1p'||product_id

update prices
set product_id = '2p'||product_id
where product_id ~ '^[0-9\.]+$'

update prices
set product_id = '3p'||product_id
where product_id ~ '^[0-9\.]+$'

select * from prices

--DESK
create table desk(
	desk_id text primary key,
	desk_name varchar(100),
	active boolean,
	last_date date
)

update desk
set desk_id = 'd'||desk_id

select * from desk

--TRANSACTIONS
create table transactions(
	transaction_id SERIAL PRIMARY KEY,
	transaction_type varchar(4),
	desk_id text NOT NULL,
	product_id text NOT NULL,
	quantity int NOT NULL,
	mv int not null,
	trans_date date not null
)

select * from transactions

--PROCEDURE FOR FEED1 TO TRANSACTIONS
create or replace procedure pr_feed1_to_trans() as
$$
	begin
		INSERT INTO
		transactions(desk_id,product_id,quantity,mv,trans_date)
		select desk_id,product_id,quantity,amount,report_date from feed1;
		
		update transactions
		set
		transaction_type = 'SELL' where quantity < 0;
		
		update transactions
		set transaction_type = 'BUY' where quantity > 0;
	end;
$$
language plpgsql

call pr_feed1_to_trans()


--INTERMEDIATE TABLE FOR FEED2 TO TRANSACTIONS
create table intermidiate_feed2_transactions(
	transaction_id SERIAL PRIMARY KEY,
	transaction_type varchar(4),
	desk_id text ,
	product_id text ,
	quantity INT ,
	mv int ,
	"date" date 
);

delete from intermidiate_feed2_transactions


--PROCEDURE FOR FEED2 TO INTERMEDIATE
create or replace procedure pr_feed2_to_interm() as
$$
	begin
		INSERT INTO 
		intermidiate_feed2_transactions
		(desk_id,transaction_type,product_id,quantity,"date")
		select 
			desk_id,
			transaction_type,
			product_id,
			quantity,
			trade_date 
		from feed2;
	end;
$$
language plpgsql

call pr_feed2_to_interm(

--PROCEDURE FOR FEED2 TO INTERMEDIATE
create or replace procedure pr_feed2_to_interm() as
$$
	begin
		INSERT INTO
		intermidiate_feed2_transactions
		(desk_id,transaction_type,product_id,quantity,"date")
		select
			desk_id,
			transaction_type,
			product_id,
			case
						when transaction_type='SELL' then
							(-1 * quantity)
						when transaction_type='BUY' then
							quantity
					end as quantity,
			trade_date
		from feed2;
	end;
$$
language plpgsql

call pr_feed2_to_interm()


--FIFO NETTING FUNCTION
select * 
from intermidiate_feed2_transactions
where desk_id = 'd18' and 
product_id = '2p106' 
order by "date"

drop function fn_getdata_bydate(desk text,product text)

--FUNCTION 
create or replace function fn_getdata_bydate(desk text,product text)
returns void as
$$
	declare
		trans_type text=null;
		qty int=0;
		r int;
		total_sum int;
		arr int[];
		temp int=0;
	begin
		
		qty = ( select sum(quantity) from(
			select * from intermidiate_feed2_transactions
			where desk_id =  desk and product_id = product
			order by "date")x)::int;
		
		if qty<0
			then total_sum = (select ts from (select sum(quantity) as ts
				from intermidiate_feed2_transactions
				group by transaction_type,desk_id,product_id
				having transaction_type='BUY' and
				desk_id = desk and
				product_id = product)x)::int;
				
			arr=array(
				select transaction_id from(
				select * from intermidiate_feed2_transactions
				where desk_id = desk and product_id = product and transaction_type='SELL'
				order by "date")x);
			
			while total_sum>0
				loop	
					temp = temp + 1;
					total_sum = total_sum + (select quantity
											 from intermidiate_feed2_transactions
							   				 where transaction_id=arr[temp])::int;
							 
					if total_sum>0
						then delete from intermidiate_feed2_transactions
							where transaction_id = arr[temp];
					elseif total_sum<=0
						then update intermidiate_feed2_transactions
							set quantity = total_sum where
							transaction_id = arr[temp];
					end if;
				end loop;
				delete from intermidiate_feed2_transactions where desk_id = desk and product_id = product and transaction_type = 'BUY';
				
		else
			total_sum = (select ts from (select sum(quantity) as ts
				from intermidiate_feed2_transactions
				group by transaction_type,desk_id,product_id
				having transaction_type='SELL'and
				desk_id = desk and
				product_id = product)x)::int;
				
			arr=array(
				select transaction_id from(
				select * from intermidiate_feed2_transactions
				where desk_id = desk and product_id = product and transaction_type='BUY'
				order by "date")x);
			
			while total_sum>0
				loop
					temp = temp + 1;
					total_sum = total_sum + (select quantity
											 from intermidiate_feed2_transactions
							   				 where transaction_id=arr[temp])::int;
							 
					if total_sum<0
						then delete from intermidiate_feed2_transactions
							where transaction_id = arr[temp];
					elseif total_sum>=0
						then update intermidiate_feed2_transactions
							set quantity = total_sum where
							transaction_id = arr[temp];
					end if;
				end loop;
				delete from intermidiate_feed2_transactions where desk_id = desk and product_id = product and transaction_type = 'SELL';
		end if;
		
	end;
$$
language plpgsql
select fn_getdata_bydate('d18','2p106')

-- PROCEDURE
create or replace procedure pr_fifo_runner() as
$$
	declare 
		d text;
		p text;
	begin
		for d,p in 
			SELECT desk_id,product_id from (
				SELECT 
					count(*) as cnt,
					desk_id,
					product_id
				FROM intermidiate_feed2_transactions
				group by 2,3 
			)p where cnt > 1
		loop
			perform fn_getdata_bydate(d,p);
		end loop;
	end;
$$
language plpgsql

call pr_fifo_runner()

SELECT 
					count(*) as cnt,
					desk_id,
					product_id
				FROM intermidiadte_feed2_transactions
				group by 2,3
				order by 1 desc
				
select * from intermidiate_feed2_transactions
where desk_id='d20' and product_id = '2p113'


delete from intermidiate_feed2_transactions;

DELETE FROM feed2_stg_fifo_positions

DELETE FROM intermediate_transactions_positions


--PROCEDURE FOR TRANSACTIONS TO POSITION WITH UPDATES(BUCKETING)
create or replace procedure pr_insert_update_bucket_pos() as
$$
	begin
		insert into intermediate_transactions_positions(
			desk_id,
			product_id,
			transaction_type,
			quantity,
			trade_date
		)
		select
			desk_id,
			product_id,
			transaction_type,
			quantity,
			"date"
		from intermidiate_feed2_transactions;
		
		update intermediate_transactions_positions
		set reporting_date = current_date;
		
		update intermediate_transactions_positions
		set age_category=1
		where (reporting_date-trade_date) >= 0 and (reporting_date-trade_date)<=30;
		
		update intermediate_transactions_positions
		set age_category=2
		where (reporting_date-trade_date) >= 31 and (reporting_date-trade_date)<=60;
		
		update intermediate_transactions_positions
		set age_category=3
		where (reporting_date-trade_date) >= 61 and (reporting_date-trade_date)<=90;
		
		update intermediate_transactions_positions
		set age_category=4
		where (reporting_date-trade_date) >= 91 and (reporting_date-trade_date)<=180;
		
		update intermediate_transactions_positions
		set age_category=5
		where (reporting_date-trade_date) >= 181 and (reporting_date-trade_date)<=360;
		
		update intermediate_transactions_positions
		set age_category=6
		where (reporting_date-trade_date) >360;
		
		delete from intermediate_transactions_positions 
		where (reporting_date-trade_date)<0;
	end;
$$
language plpgsql

call pr_insert_update_bucket_pos()

SELECT * FROM intermediate_transactions_positions


--PROCEDURE FOR INTERMEDIATE TO POSITIONS
create or replace procedure pr_interm_to_pos() as
$$
	begin
		insert into feed2_stg_fifo_positions
		(
			desk_id,
			product_id,
			transaction_type,
			age_category,
			quantity_0_30,
			quantity_31_60,
			quantity_61_90,
			quantity_91_180,
			quantity_181_360,
			quantity_GT360
		)
		select
			desk_id,
			product_id ,
			transaction_type,
			age_category,
			(
				case when age_category = 1 then quantity else 0 end
			) as quantity_0_30,
			(
				case when age_category = 2 then quantity else 0 end
			) as quantity_31_60,
			(
				case when age_category =3 then quantity else 0 end
			) as quantity_61_90,
			(
				case when age_category = 4 then quantity else 0 end
			) as quantity_91_180,
			(
				case when age_category = 5 then quantity else 0 end
			) as quantity_181_360,
			(
				case when age_category = 6 then quantity else 0 end
			) as quantity_GT360
			FROM(
				select
					desk_id,
					product_id,
					transaction_type,
					case
						when transaction_type='SELL' then
							(-1 * sum(quantity))
						when transaction_type='BUY' then
							sum(quantity)
					end as quantity,
					age_category
				from intermediate_transactions_positions
				group by 1,2,3,5) gs;
				
		update feed2_stg_fifo_positions
		set position_till_date = (quantity_0_30+
			quantity_31_60+
			quantity_61_90+
			quantity_91_180+
			quantity_181_360+
			quantity_GT360);
	end;
$$
language plpgsql

call pr_interm_to_pos()

CREATE VIEW feed2_stg_BUY_positions AS
SELECT * FROM feed2_stg_fifo_positions
WHERE transaction_type = 'BUY'

CREATE VIEW feed2_stg_SELL_positions AS
SELECT * FROM feed2_stg_fifo_positions
WHERE transaction_type = 'SELL'

SELECT count(*),product_id,desk_id from  feed2_stg_fifo_positions group by 2,3 order by 1 desc

select *
from feed2_stg_fifo_positions
where  desk_id = 'd18'
)


-- FEED2 STAGING for FIFO
create table feed2_stg_fifo_positions
(
	_id SERIAL PRIMARY KEY,
	desk_id text not null,
	product_id text not null,
	position_till_date int,
	age_category int not null,
	transaction_type varchar(4) not null,
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
)


--INTERMEDIATE TO TRANSACTIONS
create or replace procedure pr_interm_to_trans() as
$$
	begin
		INSERT INTO 
		transactions(transaction_type,desk_id,product_id,quantity,mv,trans_date)
		select transaction_type,
			desk_id,
			product_id,
			quantity,
			mv,
			"date" 
		from 
		(
			select 
				(quantity * price) as mv , 
				x.transaction_type,
				x.desk_id,
				x.product_id,
				x.quantity,
				x."date" 
			from (
				select 
					ift.transaction_type,
					ift.desk_id,
					ift.product_id,
					ift.quantity,
					p.price,ift."date"
			  FROM intermidiate_feed2_transactions ift
			  join prices p on ift.product_id = p.product_id
		)x)t1;
	end;
$$
language plpgsql

CALL pr_interm_to_trans()


-- POSITIONS
create table i_positions
(
	_id SERIAL PRIMARY KEY,
	desk_id text not null,
	product_id text not null,
	position_till_date int,
	age_category int not null,
	transaction_type varchar(4) not null,
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
)

DROP TABLE i_positions


--INTERMEDIATE FOR 
create table intermediate_transactions_positions(
	product_id text,
	desk_id text,
	transaction_type varchar(4) not null,
	quantity int,
	age_category int,
	trade_date date,
	reporting_date date
)

create or replace procedure pr_insert_update_bucket_pos() as
$$
	begin
		insert into intermediate_transactions_positions(
			desk_id,
			product_id,
			transaction_type,
			quantity,
			trade_date
		)
		select 
			desk_id,
			product_id,
			transaction_type,
			quantity,
			trans_date
		from transactions;
		
		update intermediate_transactions_positions 
		set reporting_date = current_date;

		update intermediate_transactions_positions
		set age_category=1
		where (reporting_date-trade_date) >= 0 and (reporting_date-trade_date)<=30;

		update intermediate_transactions_positions
		set age_category=2
		where (reporting_date-trade_date) >= 31 and (reporting_date-trade_date)<=60;
		
		update intermediate_transactions_positions
		set age_category=3
		where (reporting_date-trade_date) >= 61 and (reporting_date-trade_date)<=90;
		
		update intermediate_transactions_positions
		set age_category=4
		where (reporting_date-trade_date) >= 91 and (reporting_date-trade_date)<=180;
		
		update intermediate_transactions_positions
		set age_category=5
		where (reporting_date-trade_date) >= 181 and (reporting_date-trade_date)<=360;

		update intermediate_transactions_positions
		set age_category=6
		where (reporting_date-trade_date) >360;
	end;
$$
language plpgsql 

call pr_insert_update_bucket_pos()

SELECT * FROM intermediate_transactions_positions


-- FEED3 STAGING TABLE
create table feed3_stg(
	_id int primary key,
	"date" date,
	desk_id text,
	product_id text,
	section_name varchar(4),
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
);

select * from intermidiate_feed2_transactions

CREATE TABLE feed3_stg ( 
	_id int primary key,
	"date" date,
	desk_id text,
	section_name varchar(2),
	product_id text,
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
)

--PROCEDURE FOR FEE3 TO FEED3 STG TABLE
create or replace procedure sp_feed3_stg() as
$$
	
	begin
		INSERT INTO
		feed3_stg("date" ,
	desk_id ,
	product_id ,
	quantity_0_30 ,
	quantity_31_60 ,
	quantity_61_90 ,
	quantity_91_180,
	quantity_181_360 ,
	quantity_GT360 )
		select trade_date ,
	desk_id ,
	product_id ,
	quantity_0_30,
	quantity_31_60 ,
	quantity_61_90,
	quantity_91_180 ,
	quantity_181_360,
	quantity_GT360  from feed3
	where
	(quantity_0_30 >= 0 and 
			quantity_31_60 >= 0 and 
			quantity_61_90 >= 0 and 
			quantity_91_180 >= 0 and 
			quantity_181_360 >= 0 and 
			quantity_GT360 >= 0 )
	OR
	(			quantity_0_30 <= 0 and 
			quantity_31_60 <= 0 and 
			quantity_61_90 <= 0 and 
			quantity_91_180 <= 0 and 
			quantity_181_360 <= 0 and 
			quantity_GT360 <= 0 );
		
	update feed3_stg 
	set section_name = '7A'
	where quantity_0_30 >= 0 and 
			quantity_31_60 >= 0 and 
			quantity_61_90 >= 0 and 
			quantity_91_180 >= 0 and 
			quantity_181_360 >= 0 and 
			quantity_GT360 >= 0;
	
	update feed3_stg 
	set section_name = '7B'
	where quantity_0_30 <= 0 and 
			quantity_31_60 <= 0 and 
			quantity_61_90 <= 0 and 
			quantity_91_180 <= 0 and 
			quantity_181_360 <= 0 and 
			quantity_GT360 <= 0;		
		
	end;
$$
language plpgsql

call sp_feed3_stg();

select * from feed3_stg

select * from INTERMEDIATE_POSITIONS;

create table quantity_positions
(
	_id SERIAL PRIMARY KEY,
	desk_id text not null,
	product_id text not null,
	section_name varchar(2) not null,
	quantity_0_30 int default 0,
	quantity_31_60 int default 0,
	quantity_61_90 int default 0,
	quantity_91_180 int default 0,
	quantity_181_360 int default 0,
	quantity_GT360 int default 0
)

create database FinalProject

-- PROCEDURE FOR INTERMEDIATE TO I_POSITIONS
create or replace procedure pr_interm_to_pos_feed3() as
$$
	begin
		insert into i_positions(
			desk_id,
			product_id,
			transaction_type,
			quantity_0_30,
			quantity_31_60,
			quantity_61_90,
			quantity_91_180,
			quantity_181_360,
			quantity_GT360,
			age_category
		)
		select
			desk_id ,
			product_id ,
			transaction_type,
			quantity_0_30,
			quantity_31_60,
			quantity_61_90,
			quantity_91_180,
			quantity_181_360,
			quantity_GT360,
			7
		from intermediate_feed3_transactions;
	end;
$$
language plpgsql

call pr_interm_to_pos_feed3()

select * from i_positions

select * from i_positions where product_id = '2p552'