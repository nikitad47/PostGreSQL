with num as(
	select * from generate_series(1,10)
)
select * from num

with cte_director_1 as
(
	select
		*
	from movies
	inner join directors d using(director_id)
	where d.director_id = 1
)
select movie_name from cte_director_1

WITH cte_movie_count AS
    (
        SELECT
            d.director_id,
            SUM(COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0)) AS total_revenues
        FROM directors d
        INNER JOIN movies mv ON mv.director_id = d.director_id
        INNER JOIN movies_revenues r ON r.movie_id = mv.movie_id
        GROUP BY d.director_id
    )
    SELECT
       d.director_id,
       concat_ws(' ',d.first_name,d.last_name),
       cte.total_revenues
    FROM cte_movie_count cte
    INNER JOIN directors d ON d.director_id = cte.director_id;
	

-- simultaneous delete insert 
create table articles(
	article_id serial primary key,
	title varchar(100)
)

create table articles_delete as select * from articles limit 0

insert into articles (title) values
('article1'),
('article2'),
('article3'),
('article4')

select * from articles

select * from articles_delete

with cte_delete_articles as
(
	delete from articles
	where article_id = 1
	returning *
)
insert into articles_delete
select * from cte_delete_articles 

create table articles_insert as select * from articles

with cte_insert_articles as
(
	delete from articles
	returning *
)
insert into articles_insert 
select * from cte_insert_articles

select * from articles

select * from articles_insert


-- Recursive CTE
with recursive series(num_list) as
(
	select 10 
	union all
	select num_list + 5 from series
	where num_list + 5 <= 50
)
select num_list from series

create table items(
	pk serial primary key,
	name text not null,
	parent int
)

insert into items(pk,name, parent) values
(1,'vegetables',0),
(2,'fruits',0),
(3,'apple',2),
(4,'banana',2)

select * from items

with recursive cte_tree as
(
	select
		name,
		pk,
		1 as tree_level
	from items
	where parent = 0
	union
	select
		ct.name || ' -> ' || i.name,
		i.pk,
		ct.tree_level + 1
	from items i
	join cte_tree ct on ct.pk = i.parent
)
select tree_level,name from cte_tree