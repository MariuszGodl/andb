CREATE DATABASE IF NOT EXISTS tournament_dw;
USE tournament_dw;

-- external table
CREATE EXTERNAL TABLE IF NOT EXISTS date_dim (
  id INT,
  date_value STRING,
  day_of_week STRING,
  day INT,
  month INT,
  year INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION  '/user/andb36/date_dim.txt';


CREATE TABLE IF NOT EXISTS junk_dim (
  id INT,
  number_of_winning_places INT,
  entry_fee STRING
)
STORED AS TEXTFILE; 

-- bucketing into 4 buckets 
CREATE TABLE IF NOT EXISTS boardgame_dim (
  id INT,
  name STRING,
  game_category ARRAY<STRING>
)
CLUSTERED BY (id) INTO 4 BUCKETS
STORED AS ORC;


-- Dynamic as we expect the system to  assign to particular partition base on the column
CREATE TABLE IF NOT EXISTS participation_dim (
  id INT,
  --age_category STRING, - it is done by partitioning
  range_of_participants STRING
)
PARTITIONED BY (age_category STRING)
STORED AS PARQUET;

-- Static Partitioning 
CREATE TABLE IF NOT EXISTS tournament_organization_fact (
  id INT,
  board_game_id INT,
  date_id INT,
  junk_id INT,
  participation_id INT,
  prize_pool MAP<STRING,INT>
)
PARTITIONED BY (year INT) 
STORED AS ORC; 


SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
