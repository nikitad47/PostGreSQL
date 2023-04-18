--INNER JOINS
select 
	mv.movie_name,
	d.first_name,
	d.last_name
from movies mv
inner join directors d using(director_id)
inner join movies_revenues r using(movie_id)
where
	mv.movie_lang in ('English','Chinese','Japanese')
	and r.revenues_domestic>100
group by 1,2,3
	
	
select 
	mv.movie_name,
	d.first_name,
	d.last_name
from movies mv
left join directors d using(director_id)
where mv.director_id=d.director_id
	
select 
	mv.movie_name,
	concat(d.first_name,' ',d.last_name) as "director_name",
	mv.movie_lang,
	(revenues_domestic+revenues_international) as "total_revenues"
from movies mv
inner join directors d using(director_id)
inner join movies_revenues r using(movie_id)
order by 4 desc nulls last
limit 5

select 
	mv.movie_name,
	concat(d.first_name,' ',d.last_name) as "director_name",
	mv.movie_lang,
	(revenues_domestic+revenues_international) as "total_revenues",
	mv.movie_length,
	mv.release_date
from movies mv
inner join directors d using(director_id)
inner join movies_revenues r using(movie_id)
where release_date between '2005-01-01' and '2008-12-31'
order by 6 desc

--LEFT JOINS
select
	concat(d.first_name,' ',d.last_name) as director_name,
	mv.movie_name,
	mv.movie_lang
from movies mv
left join directors d on mv.director_id=d.director_id
where movie_lang in ('English','Chinese')

select 
	concat(d.first_name,' ',d.last_name) "director name",
	count(*)  "total movies"
from directors d
left join movies mv on mv.director_id=d.director_id
group by 1
order by 2 desc

select
	*
from directors d
left join movies mv on mv.director_id=d.director_id
where d.nationality in ('American','Chinese','Japanese')

select 
	concat(d.first_name,' ',d.last_name) "director name",
	sum(r.revenues_domestic+r.revenues_international) "total_revenues"
from directors d
left join movies mv on mv.director_id=d.director_id
left join movies_revenues r on r.movie_id=mv.movie_id
group by 1
order by 2 desc nulls last

--RIGHT JOINS

--FULL JOINS
select * 
from movies mv
full join directors d on mv.director_id=d.director_id

select
	concat(d.first_name,' ',d.last_name) as director_name,
	mv.movie_name,
	mv.movie_lang
from movies mv
left  join directors d on mv.director_id=d.director_id
where movie_lang in ('English','Chinese')
order by 1


-- SELF JOINS
select mv.movie_name,mv1.movie_name,mv.movie_length
from movies mv
inner join movies mv1 
on mv.movie_length=mv1.movie_length
and mv.movie_name != mv1.movie_name

select 
	m1.movie_name,
	m2.director_id
from movies m1
inner join movies m2 on m1.director_id=m2.movie_id
order by m2.director_id, m1.movie_id


--CROSS JOINS


select * from directors

select * from movies cross join directors where movies.director_id=directors.director_id

select first_name, last_name, sum(revenues_domestic+revenues_international) as total_revenues
from directors d
left join movies m using(director_id)
left join movies_revenues r using(movie_id)
group by 1,2 
having sum(r.revenues_domestic+r.revenues_international) > 0
order by 3 desc nulls last