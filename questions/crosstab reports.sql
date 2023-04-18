create extension if not exists tablefunc

select * from pg_extension

create table scores(
	score_id serial primary key,
	name varchar(100),
	subject varchar(100),
	score numeric(4,2),
	score_date date
)

insert into scores (name,subject,score,score_date) values
('Nikita','Math',10,'2020-01-01'),
('Nikita','English',8,'2020-02-01'),
('Nikita','History',7,'2020-03-01'),
('Nikita','Music',9,'2020-04-01'),
('Dara','Math',12,'2020-01-01'),
('Dara','English',10,'2020-02-01'),
('Dara','History',8,'2020-03-01'),
('Dara','Music',6,'2020-04-01')

select * from scores

select distinct(subject) from scores

select * from crosstab(
	'
		select
			name, subject, score
		from scores
	'
) as ct(
	name varchar,
	Math numeric,
	English numeric,
	History numeric,
	Music numeric 
)

select * from rainfalls;

x	years
y	location
v	sum(raindays)

select * from crosstab(
	'
		select 
			location, year, sum(raindays)::int
		from rainfalls
		group by 1,2
		order by 1,2
	'
) as ct(
	"location" text,
	"2012" int,
	"2013" int,
	"2014" int,
	"2015" int,
	"2016" int,
	"2017" int
)

select * from crosstab(
	'
		select 
			location, month, sum(raindays)::int
		from rainfalls
		group by 1,2
		order by 1,2
	'
) as ct(
	"location" text,
	"Jan" int,
	"Feb" int,
	"Mar" int,
	"Apr" int,
	"May" int,
	"Jun" int,
	"Jul" int,
	"Aug" int,
	"Sep" int,
	"Oct" int,
	"Nov" int,
	"Dec" int
)