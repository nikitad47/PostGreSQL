#!/bin/bash
​
PGPASSWORD="root" psql -h 'localhost' -U 'postgres' -d "finalproject"  --command "DELETE FROM feed2;" -c "\COPY feed2(_id,transaction_type,product_ID,quantity,trade_date,desk_id) FROM 'feed2.csv' DELIMITER ',' CSV HEADER;" -c "update feed2 set desk_id = 'd'||desk_id;" -c "update feed2 set product_id = '2p'||product_id;" -c "select COUNT(*) from feed2;"
