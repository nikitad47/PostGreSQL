select 
	concat(first_name,' ',last_name),
	date_of_birth,
	'director' "tablename"
from directors
where date_of_birth > '1970-12-31'
union
select 
	concat(first_name,' ',last_name),
	date_of_birth,
	'actor' "tablename"
from actors
where date_of_birth > '1990-12-31'
order by date_of_birth

select 
	first_name,last_name,
	'director' "tablename"
from directors
where first_name like 'A%'
union
select 
	first_name,last_name,
	'actor' "tablename"
from actors
where first_name like 'A%'
order by first_name