do
$$
begin
	if exists(
		SELECT EXISTS (
		   SELECT FROM information_schema.tables 
		   WHERE table_schema = 'nikita'
		   AND table_name   = 'movies_actors'
		)
	)
	then
		create table nikita.movies_actors(
			movie_id int references movies (movie_id),
			actor_id int references actors (actor_id),
			primary key (movie_id, actor_id)
		);
	end if;
end;
$$
language plpgsql


create table nikita.movies_actors(
	movie_id int references movies (movie_id),
	actor_id int references actors (actor_id),
	primary key (movie_id, actor_id)
);

create table nikita.movies_revenues(
	revenue_id serial primary key,
	movie_id int references movies (movie_id),
	revenues_domestic numeric(10,2),
	revenues_international numeric(10,2)
);

create table nikita.actors(
	actor_id serial primary key,
	first_name varchar(150),
	last_name varchar(150) not null,
	gender char(1),
	date_of_birth date,
	add_date date,
	update_date date
);
			
create table nikita.movies(
	movie_id serial primary key,
	movie_name varchar(100) not null,
	movie_length int,
	movie_lang varchar(20),
	age_certificate varchar(10),
	release_date date,
	director_id int references directors (director_id) 
)

create table nikita.directors(
	director_id serial primary key,
	first_name varchar(150),
	last_name varchar(150),
	date_of_birth date,
	add_date date,
	update_date date,
	nationality varchar(20),
)

drop table nikita.actors

SELECT table_name
FROM information_schema.tables
WHERE table_name = 'movies' and table_schema= 'public'
ORDER BY table_name;

SELECT column_name FROM information_schema.columns WHERE table_name = 'ratings'

SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = 'nikita'
   AND    table_name   = 'ratings'
);

SELECT 'CREATE TABLE '||'movies (' 
UNION ALL
SELECT column_name || ' ' || data_type|| CASE is_nullable WHEN 'NO' THEN ' NOT NULL' ELSE '' END||','
FROM information_schema.columns
WHERE table_schema = 'public'
AND   table_name = 'movies'
UNION ALL
SELECT ');'