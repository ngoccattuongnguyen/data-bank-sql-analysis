-- Data Bank (8 Week SQL Challenge #4) | Part A. Customer Nodes Exploration
-- PostgreSQL 13. Tables are in schema data_bank.

--unique nodes
SELECT COUNT(DISTINCT node_id) as unique_nodes
From data_bank.customer_nodes;

--number of nodes per region
SELECT r.region_name, COUNT(DISTINCT c.node_id) as count_id
FROM data_bank.customer_nodes c
JOIN data_bank.regions r ON c.region_id = r.region_id
GROUP BY r.region_name;

--How many customers are allocated to each region
SELECT r.region_name, COUNT(DISTINCT c.customer_id) as count_customer
FROM data_bank.customer_nodes c
JOIN data_bank.regions r ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY count_customer desc;

--How many days on average are customers reallocated to a different node?
SELECT ROUND(AVG(end_date -start_date), 1)
FROM data_bank.customer_nodes
WHERE end_date <> '9999-12-31';

--the median, 80th and 95th percentile for this same reallocation days metric for each region

WITH nodes_day AS(
  SELECT region_id, (end_date - start_date) AS days
  FROM data_bank.customer_nodes
  WHERE end_date <> '9999-12-31'
  
 )
 
 SELECT r.region_name,
 PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY days) AS median,
 PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY days) AS p80,
 PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY days) AS p95
 FROM nodes_day n
 JOIN data_bank.regions r ON n.region_id = r.region_id
 GROUP BY r.region_name;
