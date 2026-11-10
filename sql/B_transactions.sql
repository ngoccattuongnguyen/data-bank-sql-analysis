-- Data Bank (8 Week SQL Challenge #4) | Part B. Customer Transactions
-- PostgreSQL 13. Tables are in schema data_bank.

---Explore: transaction types
Select txn_type, count(*)
 FROM data_bank.customer_transactions
 group by txn_type;

--  the unique count and total amount for each transaction type
 
 select txn_type,
 count(*) AS txn_count,
 sum(txn_amount) AS total_amount
 from data_bank.customer_transactions
 group by txn_type;

---the average total historical deposit counts and amounts for all customers
 
 WITH customer_deposit AS(
   SELECT 
   customer_id,
   Count(*) AS deposit_count,
   SUM(txn_amount) AS deposit_amount
   FROM data_bank.customer_transactions
   where txn_type = 'deposit'
   Group by customer_id
   
  
   
   )
   
   select
   round(avg(deposit_count),1) AS avg_deposit_count,
   round(avg(deposit_amount),1) AS avg_deposit_amount
   from customer_deposit;

--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH monthly AS(
  SELECT
  customer_id,
  DATE_TRUNC('month',txn_date) AS txn_month,
  SUM(CASE WHEN txn_type = 'deposit' then 1 else 0 end) AS deposits,
  SUM(CASE WHEN txn_type = 'purchase' then 1 else 0 end) AS purchases,
  SUM(CASE WHEN txn_type = 'withdrawal' then 1 else 0 end) AS withdrawal
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_month)
  
  SELECT 
  txn_month,
  COUNT(*) AS customer_count
  FROM monthly
  WHERE deposits > 1
  AND( purchases >=1 OR withdrawal >=1)
  GROUP BY txn_month
  ORDER BY txn_month;

---the closing balance for each customer at the end of the month
WITH monthly_change AS (
  SELECT customer_id,
  DATE_TRUNC('month',txn_date) AS txn_month,
  SUM(CASE WHEN txn_type = 'deposit' then txn_amount 
      ELSE -txn_amount END) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_month)

SELECT customer_id, txn_month,
SUM(net_change) OVER (PARTITION BY customer_id ORDER BY txn_month) AS closing_balance
FROM monthly_change
ORDER BY customer_id, txn_month;

---What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_change AS (
  SELECT customer_id,
  DATE_TRUNC('month',txn_date) AS txn_month,
  SUM(CASE WHEN txn_type = 'deposit' then txn_amount 
      ELSE -txn_amount END) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_month),
  
  customer_balance AS (
   SELECT 
   customer_id,
   SUM (CASE WHEN txn_month = '2020-01-01' THEN net_change ELSE 0 END) AS start_balance,
   SUM (net_change) AS end_balance
   FROM monthly_change
   GROUP BY customer_id)
 
 SELECT
  ROUND(
    100.0 * COUNT(CASE WHEN start_balance > 0
                        AND end_balance > start_balance * 1.05
                       THEN 1 END)
    / COUNT(*)
  , 1) AS pct_customers_grew
FROM customer_balance;
