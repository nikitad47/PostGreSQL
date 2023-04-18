select * from v_all_actors_directors

create or replace view v_movies_directors_movies_revenues as
select
	*
from movies m
inner join directors d using (director_id)
inner join movies_revenues r using (movie_id)

select * from v_movies_directors_movies_revenues

select * from directors

create materialized view mv_directors2 as
select first_name
from directors
with no data

select * from mv_directors2

select relispopulated from pg_class where relname = 'mv_directors2'

refresh materialized view mv_directors2

create materialized view mv_directors_us as 
select 
	director_id,
	first_name,
	last_name,
	date_of_birth,
	nationality
from directors
where nationality = 'American'
with no data

select * from mv_directors_us

refresh materialized view mv_directors_us

refresh materialized view concurrently mv_directors_us

create unique index idx_u_mv_directors_director_id on mv_directors_us (director_id)

-- Using materialized view for a website page clicks analytics
create table page_clicks(
	rec_id serial primary key,
	page varchar(200),
	click_time timestamp,
	user_id bigint
)

insert into page_clicks (page,click_time,user_id)
select
(
	case (random() * 2)::int
		when 0 then 'klickanalytics.com'
		when 1 then 'clickapis.com'
		when 2 then 'google.com'
	end
) as page,
now() as click_time,
(floor(random() * (111111111-1000000 + 1) + 1000000))::int as user_id
from generate_series(1,10000) seq;

select * from page_clicks

create materialized view mv_page_clicks as
select
	date_trunc('day',click_time) as day,
	page,
	count(*) as total_clicks
from page_clicks
group by day,page

refresh materialized view mv_page_clicks

select * from mv_page_clicks

-- List materialized views
select oid::regclass::text
from pg_class
where relkind = 'm'
order by 1

select * from pg_matviews;

select * from pg_matviews where matviewname = 'mv_directors';


-- Query whether a materialized view exists
SELECT view_definition
FROM information_schema.views
WHERE
table_schema = 'information_schema'
AND table_name = 'views';

SELECT count(*) > 0 FROM pg_catalog.pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE
c.relkind = 'm'
AND n.nspname = 'public'
AND c.relname = 'mv_directors2';\

create table t4 (x int, y int not null)

select * from t1

explain 
select * from t1 where x = 50
union
select * from t1 where x = 100


SELECT oid::regclass AS table_column
FROM   pg_class
WHERE  relname = 't1'
AND    relkind = 'r';

create or replace view v_t4 as
select * from t4 where y=2 with local check option

create or replace view v_t4_2 as
select * from v_t4 where y=4 with local check option

select * from v_t4

alter table t4 add column z int
select * from v_t4

insert into v_t4_2(y) values (2)  --what will happen