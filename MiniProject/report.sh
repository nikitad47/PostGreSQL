#!/bin/bash

deskID="USER INPUT"
read -p "Enter desk ID: " deskID
productID="USER INPUT"
read -p "Enter Product ID: " productID

PGPASSWORD="root" psql -h 'localhost' -U 'postgres' -d "finalproject" --command "delete from INTERMEDIATE_POSITIONS;" -c "delete from feed2_stg_fifo;" -c "delete from quantity_positions;" -c "delete from feed3_stg;" -c "delete from value_positions;" -c "call sp_feed1_stg();" -c "call sp_feed2_to_stg();" -c "call sp_fifo_runner();" -c "call sp_feed2_stg();" -c "call sp_feed3_stg();" -c "call sp_insert_f1_f2_qpositions();" -c "call sp_insert_f3_qpositions();" -c "call sp_find_value_positions();" -c "SELECT * FROM value_positions WHERE desk_id=$deskID and product_id=$productID "