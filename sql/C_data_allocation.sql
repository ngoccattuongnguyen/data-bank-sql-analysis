-- Data Bank (8 Week SQL Challenge #4) | Part C. Data Allocation Challenge
-- PostgreSQL 13. Tables are in schema data_bank.

---C1:Running balance after each transaction
SELECT
  customer_id,
  txn_date,
  txn_type,
  txn_amount,
  SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
           ELSE -txn_amount END)
    OVER (PARTITION BY customer_id ORDER BY txn_date
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM data_bank.customer_transactions
ORDER BY customer_id, txn_date;

---C2: Balance at end of every month (including months with no transactions)
WITH monthly_change AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date)::DATE AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
             ELSE -txn_amount END) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_month
),
all_months AS (
  SELECT
    c.customer_id,
    GENERATE_SERIES('2020-01-01'::DATE, '2020-04-01'::DATE, INTERVAL '1 month')::DATE AS txn_month
  FROM (SELECT DISTINCT customer_id FROM data_bank.customer_transactions) c
)
SELECT
  a.customer_id,
  a.txn_month,
  COALESCE(m.net_change, 0) AS net_change,
  SUM(COALESCE(m.net_change, 0))
    OVER (PARTITION BY a.customer_id ORDER BY a.txn_month) AS closing_balance
FROM all_months a
LEFT JOIN monthly_change m
  ON a.customer_id = m.customer_id
 AND a.txn_month = m.txn_month
ORDER BY a.customer_id, a.txn_month;

---C3: Min, avg, max running balance per customer
WITH running AS (
  SELECT
    customer_id,
    txn_date,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
             ELSE -txn_amount END)
      OVER (PARTITION BY customer_id ORDER BY txn_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
  FROM data_bank.customer_transactions
)
SELECT
  customer_id,
  MIN(running_balance) AS min_balance,
  ROUND(AVG(running_balance), 1) AS avg_balance,
  MAX(running_balance) AS max_balance
FROM running
GROUP BY customer_id
ORDER BY customer_id;

---Option 1: data based on previous month-end balance
WITH monthly_change AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date)::DATE AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
             ELSE -txn_amount END) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_month
),
all_months AS (
  SELECT
    c.customer_id,
    GENERATE_SERIES('2020-01-01'::DATE, '2020-04-01'::DATE, INTERVAL '1 month')::DATE AS txn_month
  FROM (SELECT DISTINCT customer_id FROM data_bank.customer_transactions) c
),

 closing AS (
  SELECT
    a.customer_id,
    a.txn_month,
    SUM(COALESCE(m.net_change, 0))
      OVER (PARTITION BY a.customer_id ORDER BY a.txn_month) AS closing_balance
  FROM all_months a
  LEFT JOIN monthly_change m
    ON a.customer_id = m.customer_id
   AND a.txn_month = m.txn_month
)
SELECT
  txn_month AS balance_month,
  SUM(GREATEST(closing_balance, 0)) AS data_for_next_month
FROM closing
GROUP BY txn_month
ORDER BY txn_month;

---Option 3: Real Time
WITH running AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date)::DATE AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
             ELSE -txn_amount END)
      OVER (PARTITION BY customer_id ORDER BY txn_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
  FROM data_bank.customer_transactions
),
monthly_peak AS (
  SELECT
    customer_id,
    txn_month,
    MAX(running_balance) AS peak_balance
  FROM running
  GROUP BY customer_id, txn_month
)
SELECT
  txn_month,
  SUM(GREATEST(peak_balance, 0)) AS data_required
FROM monthly_peak
GROUP BY txn_month
ORDER BY txn_month;

---Option 2: average balance during the month (approximation of 30-day average)
WITH running AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date)::DATE AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
             ELSE -txn_amount END)
      OVER (PARTITION BY customer_id ORDER BY txn_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
  FROM data_bank.customer_transactions
),
monthly_avg AS (
  SELECT
    customer_id,
    txn_month,
    AVG(running_balance) AS avg_balance
  FROM running
  GROUP BY customer_id, txn_month
)
SELECT
  txn_month,
  ROUND(SUM(GREATEST(avg_balance, 0)), 0) AS data_required
FROM monthly_avg
GROUP BY txn_month
ORDER BY txn_month;
