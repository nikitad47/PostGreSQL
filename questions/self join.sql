create table opening_pairs(
    team_name varchar(20),
    player_name varchar(20));
	
	insert into opening_pairs values('India','Rahul'),('India','Rohit'),
('Australia','Khwaja'),('Australia','Warner'),
('South Africa','De Kock'),('South Africa','Miller');

select * from opening_pairs

select o1.team_name, max(o1.player_name), min(o2.player_name)
from opening_pairs o1
join opening_pairs o2 on o1.team_name=o2.team_name
where o1.player_name <> o2.player_name
group by 1
order by 1

select team_name, max(player_name), min(player_name)
from opening_pairs 
group by 1

insert into opening_pairs values ('India','C')

with cte_india as (
select team_name, max(player_name) player_1, min(player_name) player_2
from   opening_pairs op1
where team_name = 'India'
group by team_name
    )
select a.*, op.player_name from cte_india a, opening_pairs op
where a.team_name = op.team_name
and   player_1 <> player_name
and   player_2 <> player_name