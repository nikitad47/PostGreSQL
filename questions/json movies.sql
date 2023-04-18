select row_to_json(d) from (
	select director_id,concat(first_name,' ',last_name) as "director_name",nationality
	from directors
) as d

select *,
	jsonb_array_length(body->"all movies")
from directors_docs