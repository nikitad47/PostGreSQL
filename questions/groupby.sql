create table t1(x int, y int)

insert into t1 values(null,1);
insert into t1 values(2,2);
insert into t1 values(2,4);
insert into t1 values(3,6);

select x, sum(y)
from t1
group by x,y
order by case y when 1 then 0 else 2 end

select x , count(case  y when 1 then 1 else 0 end)
from t1 
where y =1
group by x 
having x=1 
and count(y)=5