select '{
		"title":"i am nikita"
	}'::json
	
--create table with json objects
create table books(
	book_id serial primary key,
	book_info jsonb
)

--insert json objects to table
insert into books (book_info) values
('
 {
 	"title":"title5",
 	"author":"author2"
 }'
),

('
 {
 	"title":"title3",
 	"author":"author3"
 }
'),
('
 {
 	"title":"title4",
 	"author":"author4"
 }
')

select * from books

--filtering data with json objects
Select 
	book_info->>'title' title, 
	book_info->>'author' author 
from books
where book_info->>'title' = 'title1'


--updating json field in json 
update books
set book_info = book_info || '{"author":"author5"}'
where book_info->>'title' = 'title5'

--adding json field to object
update books
set book_info = book_info || '
{
	"category":"abc",
	"pages":250
}'
where book_info->>'title' = 'title1'
returning *

--deleting field from json objects
update books
set book_info = book_info - 'pages'
where book_info->>'title' = 'title1'
returning *


--adding array firld to json objects
update books
set book_info = book_info || '
{
	"locations":[
		"India",
		"London"
	]
}'
where book_info->>'title' = 'title2'
returning *


--deleting array element from json object
update books
set book_info = book_info #- '{locations,0}'
where book_info->>'title' = 'title2'
returning *