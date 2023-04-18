-- match teams
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

-- warehouse
select 
    item_name, 
    warehouse, 
    count(item_name)
from warehouses
where item_name='cars'
group by 1,2
order by 3 desc, 2 asc
limit 1

-- quantity
select 
    order_id,
    product_id,
    buyer
from quantity
where quantity_ordered=6
order by 3

-- friends-likes
select distinct
    f.friend_id,
    l.page_id
from friends f ,likes l
where f.user_id=l.user_id
and f.friend_id not in(
    select l2.user_id
    from likes l2
    where l2.page_id=l.page_id
    -- and l2.user_id <> f.user_id
)

-- library
select
    *
from library l
where rating = (
    select max(rating)
    from library l1
    where l1.years=l.years
)
order by years

-- person_details
select
    * 
from (
    select
        person_name,
        gmail_id,
        row_number() over ()
    from person_details
    limit 5
) p
order by person_name

-- queries
select query_id from queries
where query like '%2018%'

-- survey_data
SELECT 
    substring(email_id FROM position('@' IN email_id) + 1) domain_name,
    count(email_id) "no_of_user"
FROM survey_data
group by 1
order by 1;

-- Insurance Policy
select
    customer_id,
    (claim_amount+(claim_amount/2))::double precision "grand_amount"
from insurance where 
    insurance_type='Life' and
    any_injury = 'N' and
    incident_severity = 'Major' and
    employment_status = 'Y' and
    claim_amount < (30*premium_amount)
	
-- bank
select
    customer_id
from bank 
where extract('month' from info_date)::int = 10
order by customer_id

-- christmas sale
select 
    c.id "customer_id",
    c.name "customer_name",
    c.city,
    o.order_no,
    o.order_date
from customer c
join orders o on c.id=o.customer_id
where o.order_date = '2012-12-25'
order by 1

-- suspicious claims
select 
    id,
    case
        when (employment ='N'and
            incident_severity='Major' and
            risk = 'High') then 1
        else 0
    end as "suspicious"
from claims

-- malicious hack
select 
    month, 
    number_of_attacks 
from (
    select 
        month, 
        number_of_attacks , 
        dense_rank() over (order by number_of_attacks desc)
    from(
        select 
            month::int, 
            sum(number_of_attacks) as number_of_attacks
        from(
            select
                EXTRACT(MONTH from dates) as month, 
                number_of_attacks
            from hacks 
            group by month, number_of_attacks
        ) p
    group by month
    order by number_of_attacks
    ) t
) z 
where dense_rank = 1

--maximum tip
select 
    customer_id 
from customer_review
where lower(customer_name) like '%kate'
order by tip_amount desc
limit 1;

-- baseball tournament
select 
    * 
from teams t1 cross join teams t2 
where t1.team_name <> t2.team_name 
order by 1,2

-- alternate records
select id, name
from (
    select
        *,
        row_number() over(order by id) "row"
    from records) a
where row%2<>0

-- baseball stadiums
select 
    stadium_name, area::numeric(10,1)
from(
select
    s.name "stadium_name",
    3.14159265358979*((s.diameter_of_the_stadium/2)*(s.diameter_of_the_stadium/2)) "area"
from stadiums s
join locations l using(location_id)
where l.name in ('California','Newyork')
order by 2 desc
) n

-- cms metrics
select
    customer_number,
    clicks,
    rank() over(order by clicks) "click_rank",
    impressions,
    rank() over(order by impressions) "impression_rank",
    new_users,
    rank() over(order by new_users) "new_user_rank",
    repeat_users,
    rank() over(order by repeat_users) "repeat_user_rank"
from metrics
order by customer_number asc

-- posts shared among groups
select 
    pd.post_id,
    p.poster_name "posted_by"
from post_details pd
join poster p on pd.posted_by = poster.poster_id
where p.poster_name = 'Mike' and pd.posted_by = poster.poster_id

-- mario and luigi
select
    c.name,
    sum(case 
        when cause_of_death = 'Eaten by the wild plant' 
            then coins_earned - (10+(obstacles_hit*2)) 
        when cause_of_death = 'Hit by the bull' 
            then coins_earned - (5+(obstacles_hit*2))
        when cause_of_death = 'Fell down in a pit' 
            then coins_earned - (3+(obstacles_hit*2))
        when cause_of_death = 'Caught by the wild plant' 
            then coins_earned - (3+(obstacles_hit*2))
    end) "total_score"
from characters c
join lives l on c.id = l.character_id
group by 1
order by 2 desc

-- source and destination
select 
    * 
from routes
where source < destination
order by distance desc, source, destination;

-- keep the duplicates away
-- select id->>0 "id",gmail_id from
-- (
-- select
--     jsonb_agg(person_id)as id,
--     gmail_id
-- from person
-- group by 2
-- ) a

select 
    min(person_id),
    gmail_id
from person
group by 2
order by 1

-- family's earning children
select 
    count(*) 
from(
    select 
        sibling_rank, 
        sibling_name, 
        15+ (
            select 
                sum(age_diff) 
            from siblings s2
            where s2.sibling_rank <= s1.sibling_rank
            ) as age
    from siblings s1
) a
where age >= 20

-- Fine friends
SELECT 
    p1.p_name,
    p2.p_name 
from people p1 
cross join people p2 
where concat(p1.p_id,p2.p_id) in 
(
    select 
        concat(tid,cid) 
    from 
    (
        select 
            t1.p_id as tid,
            t1.connect_ID as cid, 
            t2.p_id,
            t2.connect_ID 
        from request_sent t1 , request_sent t2 
        where (t1.p_ID = t2.connect_ID and t2.p_ID = t1.connect_ID) 
        and t1.p_ID < t2.p_ID
    ) p
) order by 1,2

-- the place of goals
select 
    location_name,
    goal_count 
from
(
    select 
        location_name ,
        goal_count,
        dense_rank() over(order by goal_count desc) 
    from 
    (
        select 
            count(*) as goal_count,
            l.location_name
        from goals g
        inner join fixtures f on f.fixture_id = g.match_no
        inner join locations l on l.location_id = f.location_id 
        group by l.location_name
        order by 1 desc , 2 asc 
    ) x
) z where dense_rank = 1

-- Union corporation of companies
select 
    cp.company_code,
    cp.founder,
(  
    select 
        count(*) 
    from company c
    inner join lead_manager lm on c.company_code = lm.company_code 
    group by c.company_code
    having c.company_code  = cp.company_code
) as count_of_LMs,
(
    select 
        count(*) 
    from company c
    inner join senior_manager sm on c.company_code = sm.company_code 
    group by c.company_code
    having c.company_code  = cp.company_code
) as count_of_SMs,
(
    select 
        count(*) 
    from company c
    inner join manager m on c.company_code = m.company_code 
    group by c.company_code
    having c.company_code  = cp.company_code
) as count_of_Ms,
(
    select 
        count(*) 
    from company c
    inner join employee e on c.company_code = e.company_code 
    group by c.company_code
    having c.company_code  = cp.company_code
) as count_of_Es
from company cp

-- department details
select 
    ed.dep_id,
    d.dep_name,
    sum(es.sales) as total_sales
from empsales es
join empdetails ed using(emp_id)
join department d on ed.dep_id=d.dep_id
group by ed.dep_id,d.dep_name
order by  total_sales desc
limit 1;

-- profit rate
select 
    d.director_name, 
    (((avg(boxoffice_in_million)-avg(budget_in_million)))/100)::numeric(4,2) 
from film f join director d on d.director_id=f.director_id
group by 1
order by 2 desc;

-- find the trains
select 
    count(*) 
from train_details 
where train_type = (
    select 
        type_id 
    from train_type_details 
    where type_name = 'Express'
    ) 
    and train_from = (
        select 
            station_id 
        from station_details 
        where station_name = 'New York'
        ) 
        and (
            train_to = (
                select 
                    station_id 
                from station_details 
                where station_name = 'Washington'
                ) 
                or train_to = (
                    select 
                        station_id 
                    from station_details 
                    where station_name = 'Pennsylvania'
                    )
                );
				
-- denormalisation
select 
    student_id,
    name,
(
    select 
        score 
    from students s2 
    where subject = 'maths' and s1.student_id = s2.student_id
) as "maths",
(
    select 
        score 
    from students s2 
    where subject = 'physics' and s1.student_id = s2.student_id
) as "physics",
(
    select 
        score 
    from students s2 
    where subject = 'chemistry' and s1.student_id = s2.student_id
) as "chemistry" 
from students s1
group by student_id,name
order by student_id;

-- max shop type
select 
    type_id,
    name 
from (
    select 
        count(*) as cnt ,
        type_id, 
        name 
    from type_details 
    join shop_type using (type_id) 
    group by 2,3
    having cnt = (
        (
            select 
                max(count_of_stype) 
            from (
                select 
                    count(type_id) as count_of_stype
                from shop_type 
                group by type_id 
                order by 1 desc
            )x 
        )
    )
)f

