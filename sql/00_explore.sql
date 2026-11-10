-- Data Bank (8 Week SQL Challenge #4) | Data exploration
-- PostgreSQL 13. Tables are in schema data_bank.

SELECT COUNT(*) FROM data_bank.customer_transactions;

SELECT COUNT(*) FROM data_bank.customer_nodes;

SELECT MIN(txn_date), MAX(txn_date) FROM data_bank.customer_transactions;

SELECT end_date,  COUNT(*) FROM data_bank.customer_nodes
GROUP BY end_date
ORDER BY end_date desc;

SELECT COUNT(DISTINCT customer_id)
FROM data_bank.customer_nodes;
