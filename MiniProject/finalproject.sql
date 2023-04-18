--COPY COMMANDS
\COPY feed1(_id,report_date,product_id,desk_id,quantity,amount) FROM 'feed1.csv' DELIMITER ',' CSV HEADER;

\COPY feed2(_id,transaction_type,product_ID,quantity,trade_date,desk_id) FROM 'feed2.csv' DELIMITER ',' CSV HEADER;

\COPY feed3(_id,report_date,desk_id,product_id,quantity_0_30,quantity_31_60,quantity_61_90,quantity_91_180,quantity_181_360,quantity_GT360) FROM 'feed3.csv' DELIMITER ',' CSV HEADER;

\COPY prices(product_id,price,update_date) FROM 'prices1.csv' DELIMITER ',' CSV HEADER;
\COPY prices(product_id,price,update_date) FROM 'prices2.csv' DELIMITER ',' CSV HEADER;
\COPY prices(product_id,price,update_date) FROM 'prices3.csv' DELIMITER ',' CSV HEADER;

\COPY desk(desk_id,desk_name,active,last_date) FROM 'desk.csv' DELIMITER ',' CSV HEADER;

--FEED1
CREATE TABLE feed1
(
	_id serial PRIMARY KEY,
	report_date date not null,
	desk_id text not null ,
	product_id text not null,
	quantity int not null default 0 ,
	amount int not null default 0
);

select * from feed1;
delete from feed1
update feed1
set desk_id = 'd'||desk_id;

update feed1
set product_id = '1p'||product_id;

--FEED2
create table feed2(
	_id SERIAL PRIMARY KEY,
	transaction_type varchar(4) not null,
	product_id text not null,
	quantity int not null,
	trade_date date not null,
	desk_id text not null
);

select * from feed2;

update feed2
set desk_id = 'd'||desk_id;

update feed2
set product_id = '2p'||product_id;

--FEED3
create table feed3(
	_id int primary key,
	report_date date,
	desk_id text,
	product_id text,
	quantity_0_30 int,
	quantity_31_60 int,
	quantity_61_90 int,
	quantity_91_180 int,
	quantity_181_360 int,
	quantity_GT360 int
);

select * from feed3;

update feed3
set desk_id = 'd'||desk_id;

update feed3
set product_id = '3p'||product_id;

--PRICES
create table prices (
	product_id text primary key not null,
	price int not null,
	updated_date date not null
);

update prices
set product_id = '1p'||product_id;

update prices
set product_id = '2p'||product_id
where product_id ~ '^[0-9\.]+$';

update prices
set product_id = '3p'||product_id
where product_id ~ '^[0-9\.]+$';

select * from prices;

--DESK
create table desk(
	desk_id text primary key,
	desk_name varchar(100),
	active boolean,
	last_date date
);

update desk
set desk_id = 'd'||desk_id;

select * from desk;

--INTERMEDIATE POSITIONS
CREATE TABLE delete from INTERMEDIATE_POSITIONS ( 
	_id SERIAL PRIMARY KEY,
	section_name varchar(4),
	desk_id text ,
	product_id text ,
	age_category int,
	total_qty_till_date int,
	quantity INT ,
	mv int ,
	"date" date 		
);

delete from INTERMEDIATE_POSITIONS;

--PROCEDURE FOR FEED1 TO INTERMEDIATE_POSITIONS
create or replace procedure sp_feed1_stg() as
$$
	begin
		INSERT INTO
		INTERMEDIATE_POSITIONS(desk_id,product_id,quantity,mv,"date")
		select desk_id,product_id,quantity,amount,report_date from feed1;
		
		update INTERMEDIATE_POSITIONS
		set
		section_name = '7B' where quantity < 0;
		
		update INTERMEDIATE_POSITIONS
		set section_name = '7A' where quantity > 0;
		
		update INTERMEDIATE_POSITIONS
		set section_name = 'NA' where quantity = 0;
	end;
$$
language plpgsql

call sp_feed1_stg();

select * from INTERMEDIATE_POSITIONS;

--FEED2 STAGING TABLE
CREATE TABLE feed2_stg_fifo ( 
	_id SERIAL PRIMARY KEY,
	transaction_type varchar(4),
	desk_id text ,
	product_id text ,
	quantity INT ,
	"date" date 		
);

delete from feed2_stg_fifo;

--PROCEDURE FOR FEED2 TO STAGGING
create or replace procedure sp_feed2_to_stg() as
$$
	begin
		INSERT INTO
		feed2_stg_fifo
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

call sp_feed2_to_stg();

select * from feed2_stg_fifo;


--FIFO NETTING FUNCTION
select * 
from feed2_stg_fifo
where desk_id = 'd18' and 
product_id = '2p106' 
order by "date";

drop function fn_fifo(desk text,product text);

create or replace function fn_fifo(desk text,product text)
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
		qty = (select sum(quantity) from(
					select * from feed2_stg_fifo
					where desk_id =  desk and product_id = product
					order by "date")
			   x)::int;
		
		if qty<0
			then total_sum = (select ts from (select sum(quantity) as ts
				from feed2_stg_fifo
				group by transaction_type,desk_id,product_id
				having transaction_type='BUY' and
				desk_id = desk and
				product_id = product)x)::int;
				
			arr=array(
				select _id from(
				select * from feed2_stg_fifo
				where desk_id = desk and product_id = product and transaction_type='SELL'
				order by "date")x);
			
			while total_sum>0
				loop	
					temp = temp + 1;
					total_sum = total_sum + (select quantity
											 from feed2_stg_fifo
							   				 where _id=arr[temp])::int;
							 
					if total_sum>0
						then delete from feed2_stg_fifo
							where _id = arr[temp];
					elseif total_sum<=0
						then update feed2_stg_fifo
							set quantity = total_sum where
							_id = arr[temp];
					end if;
				end loop;
				delete from feed2_stg_fifo where desk_id = desk and product_id = product and transaction_type = 'BUY';
				
		else
			total_sum = (select ts from (select sum(quantity) as ts
				from feed2_stg_fifo
				group by transaction_type,desk_id,product_id
				having transaction_type='SELL'and
				desk_id = desk and
				product_id = product)x)::int;
				
			arr=array(
				select _id from(
				select * from feed2_stg_fifo
				where desk_id = desk and product_id = product and transaction_type='BUY'
				order by "date")x);
			
			while total_sum>0
				loop
					temp = temp + 1;
					total_sum = total_sum + (select quantity
											 from feed2_stg_fifo
							   				 where _id=arr[temp])::int;
							 
					if total_sum<0
						then delete from feed2_stg_fifo
							where transaction_id = arr[temp];
					elseif total_sum>=0
						then update feed2_stg_fifo
							set quantity = total_sum where
							_id = arr[temp];
					end if;
				end loop;
				
				delete from feed2_stg_fifo 
				where desk_id = desk and 
				product_id = product and 
				transaction_type = 'SELL';
				
		end if;
	end;
$$
language plpgsql

select fn_fifo('d18','2p106');


--PROCEDURE FOR FIFO EXECUTION
create or replace procedure sp_fifo_runner() as
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
				FROM feed2_stg_fifo
				group by 2,3 
			)p where cnt > 1
			
		loop
			perform fn_fifo(d,p);
		end loop;
	end;
$$
language plpgsql

call sp_fifo_runner();

SELECT 
	count(*) as cnt,
	desk_id,
	product_id
FROM feed2_stg_fifo
group by 2,3
order by 1 desc;


--PROCEDURE FOR FEED2 TO STG
create or replace procedure sp_feed2_stg() as
$$
	declare
		reporting_date date := current_date;
	begin
		INSERT INTO
		INTERMEDIATE_POSITIONS(desk_id,product_id,quantity,"date")
		select desk_id,product_id,quantity,"date" from feed2_stg_fifo;
		
		update INTERMEDIATE_POSITIONS
		set
		section_name = '7B' where quantity < 0;
		
		update INTERMEDIATE_POSITIONS
		set section_name = '7A' where quantity > 0;
		
		update INTERMEDIATE_POSITIONS
		set section_name = 'NA' where quantity = 0;
		
		
		update INTERMEDIATE_POSITIONS
		set age_category=1
		where (reporting_date-"date") >= 0 and (reporting_date-"date")<=30;

		update INTERMEDIATE_POSITIONS
		set age_category=2
		where (reporting_date-"date") >= 31 and (reporting_date-"date")<=60;
		
		update INTERMEDIATE_POSITIONS
		set age_category=3
		where (reporting_date-"date") >= 61 and (reporting_date-"date")<=90;
		
		update INTERMEDIATE_POSITIONS
		set age_category=4
		where (reporting_date-"date") >= 91 and (reporting_date-"date")<=180;
		
		update INTERMEDIATE_POSITIONS
		set age_category=5
		where (reporting_date-"date") >= 181 and (reporting_date-"date")<=360;

		update INTERMEDIATE_POSITIONS
		set age_category=6
		where (reporting_date-"date") >360;
	end;
$$
language plpgsql

call sp_feed2_stg();

select * from INTERMEDIATE_POSITIONS;

--FEED3 STAGING TABLE
CREATE TABLE feed3_stg( 
	_id serial primary key,
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
);

delete from feed3_stg;

--PROCEDURE FOR FEED3 TO STAGING TABLE
create or replace procedure sp_feed3_stg() as
$$
	begin
		INSERT INTO feed3_stg(
			"date" ,
			desk_id ,
			product_id ,
			quantity_0_30 ,
			quantity_31_60 ,
			quantity_61_90 ,
			quantity_91_180,
			quantity_181_360 ,
			quantity_GT360 )
		select 
			report_date ,
			desk_id ,
			product_id ,
			quantity_0_30,
			quantity_31_60 ,
			quantity_61_90,
			quantity_91_180 ,
			quantity_181_360,
			quantity_GT360  
			from feed3
			where(quantity_0_30 >= 0 and 
				quantity_31_60 >= 0 and 
				quantity_61_90 >= 0 and 
				quantity_91_180 >= 0 and 
				quantity_181_360 >= 0 and 
				quantity_GT360 >= 0 )
			OR
			(quantity_0_30 <= 0 and 
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

select * from feed3_stg;

--QUANTITY POSITIONS(BUCKETS)
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
);

delete from quantity_positions;

--PROCEDURE FOR INTERM POS TO QUANT POS
create or replace procedure sp_insert_f1_f2_qpositions() as
$$
	begin
		insert into quantity_positions
		(
			desk_id,
			product_id,
			section_name,
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
			section_name,
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
		FROM
			(select 
				desk_id,
				product_id,
				section_name,
			 	age_category,
				quantity
			from INTERMEDIATE_POSITIONS
		)x;
	end;
$$
language plpgsql

call sp_insert_f1_f2_qpositions();

select * from quantity_positions

--PROCEDURE FOR FEED3 STAGING TABLE TO QUANT POS
create or replace procedure sp_insert_f3_qpositions() as
$$
	begin
		insert into quantity_positions
		(
			desk_id,
			product_id,
			section_name,
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
			section_name,
			quantity_0_30,
			quantity_31_60,
			quantity_61_90,
			quantity_91_180,
			quantity_181_360,
			quantity_GT360
		FROM feed3_stg;
	end;
$$
language plpgsql

call sp_insert_f3_qpositions();

select * from quantity_positions;

--REPORT TABLE
create table value_positions
(
	_id SERIAL PRIMARY KEY,
	report_date date default current_date,
	desk_id text not null,
	product_id text not null,
	section_name varchar(2) not null,
	value_0_30 int default 0,
	value_31_60 int default 0,
	value_61_90 int default 0,
	value_91_180 int default 0,
	value_181_360 int default 0,
	value_GT360 int default 0
);

delete from value_positions;

select * from value_positions;


--PROCEDURE FOR STORING VALUES IN VALUE BUCKETS
create or replace procedure sp_find_value_positions() as
$$
	begin
		insert into value_positions
		(
			desk_id,
			product_id,
			section_name,
			value_0_30,
			value_31_60,
			value_61_90,
			value_91_180,
			value_181_360,
			value_GT360
		)
		select
			desk_id,
			product_id ,
			section_name,
			quantity_0_30 * price,
			quantity_31_60 * price,
			quantity_61_90 * price,
			quantity_91_180 * price,
			quantity_181_360 * price,
			quantity_GT360 * price
			FROM(
				SELECT * 
				FROM quantity_positions  
				JOIN prices using (product_id)
			)s;
	end;
$$
language plpgsql

call sp_find_value_positions();

select * from value_positions;
order by 9 desc;

select * from feed2;

SELECT * FROM value_positions order by desk_id WHERE desk_id='d18' and product_id='2p106';