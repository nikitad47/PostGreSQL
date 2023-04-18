select char_length('nikita'),char_length(trim(' nikita ')),char_length(' nikita ')

select 'same' similar to ' same'

select 'same' similar to 's%'

select 'same' similar to '%s'

select 'same' similar to '%(s|a)%'

select 'same' similar to '(m|e)%'

-- POSIX
select 'same' ~ 'same'

select 'same' ~ 'Same'

select 'same' ~* 'Same'

select 'same' !~ 'same'

select 'same' !~* 'Same'

select substring('nikita dara' from 'nikita..')

select substring('nikita dara' from '\w+')

select substring('nikita dara' from '\w+.$')

select substring('nikita dara 4 07 2001 12 a.m' from '\d{2,4} (?:a.m|p.m)')

select substring('nikita dara 4 07 2001 12 a.m' from '(a.m|p.m)')

select substring('nikita dara was born on 4 07 2001 at 12 a.m' from 'nikita|nikki')

select substring('nikita dara was born on July 4, 2001 at 12 a.m' from 'July \d{1}, \d{4}')

select substring('nikita dara was born on 4-7-2001 at 12 a.m' from '\d{1}-\d{1}-\d{4}')

select substring('nikita dara  was born on July 4, 2001 at 12 a.m' from '\s{2}.+')

-- REGEXP_MATCHES
select regexp_matches('Nikita #Dara','#')

select regexp_matches('Nikita #Dara','#.+')

select regexp_matches('Nikita #Dara','#(.+)')

select regexp_matches('Nikita #Dara','#([A-Za-z0-9_])')

select regexp_matches('Nikita #Dara','#([A-Za-z0-9_]+)')

select regexp_matches('Nikita #Dara','#([A-Za-z0-9_]+)')

select regexp_matches('Nikita #Dara #SQL','#([A-Za-z0-9_]+)','g')

select regexp_matches('XYZ','x','g')

select regexp_matches('XYZ','^(X)(..)$','g')


-- REGEXP_REPLACE
select regexp_replace('Nikita #Dara #SQL','#','.','g')

select regexp_replace('Nikita Dara','(.*) (.*)','\2 - \1')


-- REGEXP_SPLIT_TO_TABLE
select regexp_split_to_table('1,2,3,4,5',',')

select regexp_split_to_table('nikita/dara','/')

select regexp_split_to_table('nikita,narendra,dara',',')


-- REGEXP_SPLIT_TO_ARRAY
select regexp_split_to_array('1,2,3,4,5',',')

select regexp_split_to_array('1 2 3 4 5',' ')

select array_length(regexp_split_to_array('1 2 3 4 5',' '),1)


