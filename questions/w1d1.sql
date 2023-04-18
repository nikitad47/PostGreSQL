create or replace function fn_return_table(out res int)
returns int as
$$
-- declare 
-- var int;
begin
-- 	return ;
	select count(*) 
	from movies
	group by director_id
	order by 1 desc	
	into res;	
end;
$$
language plpgsql

select fn_return_table()
