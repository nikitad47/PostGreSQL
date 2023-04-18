select 
	coalesce(c1.table_name,c2.table_name) as table_name
	coalesce(c1.column_name,c2.column_name) as table_column