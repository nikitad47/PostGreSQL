select * from t1

select * from t2

--find records of one table taht does not exist in another table

--using not exists
select *
from t2
where not exists (
	select *
	from t1
	where t1.id = t2.id
);

--using left outer join
select *
from t2
left outer join t1
	on (t2.id=t1.id)
	where t1.id is null
	
	
--implement full outer join using left and right outer join
	
select * 
from t1
full outer join t2
	on t2.id=t1.id
union all
select * 
from t1
right outer join t2
	on t1.id=t2.id

select count(t1.*) from t1 join t2 on t1.id=t2.id

update t1 set id = null where id=1
