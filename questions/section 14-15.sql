select 
	initcap(first_name) as fname,
	initcap(last_name) as lname
from directors;

select initcap('hey nikita how are you')

select reverse('nikita')

select split_part('nikita|narendra|dara','|',3)

select rpad('nikita',2,'*')

select char_length('123456')

select position('I' in 'nIkita')

select strpos('nikita dara','nikita')

select substring('nikita dara' from 1 for 8)

select substring('nikita dara' for 4)

select substring('nikita dara',2,4)

select repeat('*',4)

select replace('nikita dara', 'dara','Dara')

select count(*) from movies

select count(*) 
from movies
where movie_lang='English'

select count(1) from movies

select sum(movie_length) from movies
where movie_lang='English'

select min(release_date) from movies
where movie_lang = 'Chinese'

select movie_lang, release_date from movies
where movie_lang = 'English'
order by release_date 

select min(movie_length) from movies

select greatest('abc','def','abe')

select avg(distinct movie_length) from movies
where movie_lang='English'

--select sum(movie_name::int) from movies can't do sum of movie names

select sum(movie_length) as Sum, avg(movie_length) as Average
from movies
where movie_lang='Japanese'				

select revenues_international + revenues_domestic as total_revenue 
from movies_revenues
where (revenues_international + revenues_domestic) is not null
order by 1 desc nulls last



--select movie_length + movie_lang as sub from movies does not work with characters

