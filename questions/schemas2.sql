create schema schema2

alter table public.t1 set schema schema2

select * from table1

insert into schema2.table1 values(4),(5),(6)

select current_schema()

show search_path

set search_path to public,nikita,schema2
alter schema schema2 owner to nikita