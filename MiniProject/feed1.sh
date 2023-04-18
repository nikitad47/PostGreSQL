#!/bin/bash

PGPASSWORD="root" psql -h 'localhost' -U 'postgres' -d "finalproject" --command "DELETE FROM feed1;" -c "\COPY feed1(_id,report_date,product_id,desk_id,quantity,amount) FROM 'feed1.csv' DELIMITER ',' CSV HEADER;" -c "update feed1 set desk_id = 'd'||desk_id;" -c "update feed1 set product_id = '1p'||product_id;" -c "select COUNT(*) from feed1;"