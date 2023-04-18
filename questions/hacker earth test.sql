-- 1
select s.team_1_id, t.name, sum(s.team_1_total_score)
from (
select
    team_1_id,
    sum(team_1_score) team_1_total_score
from match_details
group by 1
union all
select
    team_2_id,
    sum(team_2_score) team_2_total_score
from match_details
group by 1
) s
join team_details t on s.team_1_id=t.team_id
group by 1,2
order by 1