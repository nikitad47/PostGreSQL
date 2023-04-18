select 
	department_id,
	round(max(salary),2) "Max Salary",
	round(min(salary),2) "Min Salary",
	round(sum(salary),2) "Sum Salary",
	round(avg(salary),2) "Avg Salary"
from employees
group by department_id;

select
	job_id,
	max(salary) "Max Salary"
from employees
group by 1
having max(salary) >= 5000;

select
	job_id,
	max(salary) "Max Salary",
	min(salary) "Min Salary",
	max(salary)-min(salary) "Difference"
from employees
group by job_id;

select 
	job_id,
	array_agg(employee_id) as "Emp ID''s"
from employees
group by 1; 

select
	first_name
from employees
where first_name like 'A%' or 
first_name like 'C%' or
first_name like 'M%';

select 
	count(distinct(job_id)) "Unique Destinations" 
from employees;

select
	concat_ws(' ',first_name,last_name) "Name",
	department_id
from employees
where department_id in (30,100)
order by 2 asc;

select
	concat_ws(' ',first_name,last_name) "Name",
	department_id,
	salary
from employees
where department_id in (30,100) and
	salary not between 10000 and 20000;
	
select
	count(*),
	round(avg(salary),2)
from employees;

select 
	last_name
from employees
where last_name like '______'; 