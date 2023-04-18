show datestyle;

set datestyle = 'ISO, MDY'

select now()

select make_interval(weeks=>10)

select * from pg_timezone_addrev

select extract('century' from current_timestamp)

select '20200101'::date + 5

select time '23:58:58' + interval '1 hour'

select 
now(),
transaction_timestamp(),
statement_timestamp(),
clock_timestamp()

select timeofday()

show time zone

set time zone 'Asia/Calcuta'

select date_part('doy',timestamp '2017-01-01') as "year"

select date_trunc('month',timestamp '2020-10-01 05:15:45')