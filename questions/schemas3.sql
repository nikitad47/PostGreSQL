-- copy schema data
pg_dump -d hr -h localhost -U postgres -n public > dump.sql 

--rename schema public to old_schema

--importing dumped file
psql -h localhost -U postgres -d hr -f dump.sql

select * from information_schema.schemata

grant usage on schema hr to postgres