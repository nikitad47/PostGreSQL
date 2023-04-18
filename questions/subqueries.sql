-- WHERE
select 
	movie_name,
	movie_length
from movies
where movie_length > (
	select 
		avg(movie_length)
	from movies
)
order by 2

select 
	movie_name,
	movie_length,
	movie_lang
from movies
where movie_length > (
	select 
		avg(movie_length)
	from movies
	where movie_lang = 'English'
)
and movie_lang='English'
order by 2

select
	concat_ws(' ',first_name,last_name),
	date_of_birth
from actors
where date_of_birth <
(
	select
		date_of_birth
	from actors
	where first_name = 'Douglas'
)
order by 2 desc

select date_of_birth, first_name from actors
where first_name = 'Douglas'
order by 1, 2

-- IN
select 
	movie_name,
	movie_lang
from movies
where movie_id in (
	select 
		movie_id
	from movies_revenues
	where revenues_domestic > 200
)

select 
	movie_id,
	movie_name,
	movie_lang
from movies
where movie_id in (
	select 
		movie_id
	from movies_revenues
	where revenues_domestic > revenues_international
)

-- JOINS
select 
	d.director_id,
	concat_ws(' ',d.first_name, d.last_name) "director name",
	(r.revenues_domestic + r.revenues_international) "total revenues"
from directors d
inner join movies m using(director_id)
inner join movies_revenues r using(movie_id)
where (r.revenues_domestic + r.revenues_international) >
(
	select
		avg(revenues_domestic + revenues_international) "avg total revenues"
	from movies_revenues
)
order by 3

SELECT
        d.director_id,
        SUM(COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0)) AS "totaL_reveneues"
    FROM directors d
    INNER JOIN movies mv ON mv.director_id = d.director_id
    INNER JOIN movies_revenues r ON r.movie_id = mv.movie_id
    WHERE
        COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0) >
        (
            SELECT
                AVG(COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0)) as "avg_total_reveneues"
            FROM movies_revenues r
            INNER JOIN movies mv ON mv.movie_id = r.movie_id
            WHERE mv.movie_lang = 'English'
        )
    GROUP BY d.director_id
    ORDER BY 2, 1
	
select
	*
from (
	select
		*
	from movies
) m

-- Select without a from
select (
	select
		min(movie_length)
	from movies
),
(
	select
		max(movie_length)
	from movies
)

-- Correlated Subqueries
select
	mv1.movie_name,
	mv1.movie_lang,
	mv1.movie_length,
	mv1.age_certificate
from movies mv1
where mv1.movie_length > (
	select 
		min(movie_length)
	from movies mv2
	where mv1.age_certificate=mv2.age_certificate
)
order by 3

select 
	concat_ws(' ',a.first_name,a.last_name) "actor name",
	a.date_of_birth,
	a.gender
from actors a 
where a.date_of_birth > (
	select
		min(a2.date_of_birth)
	from actors a2
	where a.gender=a2.gender
)
order by 3,2

select
	*
from movies
where director_id in (
	select director_id from directors
)

select m.movie_name
from   movies m, movies_revenues mr
where  m.movie_id = mr.movie_id
and    mr.revenues_domestic > mr.revenues_international
-- both same 
select m.movie_name
from   movies m
where  movie_id in (select movie_id
                    from   movies_revenues mr
                    where  mr.revenues_domestic > 
mr.revenues_international)