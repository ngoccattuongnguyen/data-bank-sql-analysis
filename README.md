# Data Bank: Data Provisioning Analysis (SQL)

Case Study #4 from the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-4/), solved in PostgreSQL 13.

**Business question:** Data Bank gives customers cloud storage equal to their account balance. How much storage must the bank provision each month under three allocation options?

**Live queries:** [DB Fiddle](https://www.db-fiddle.com/f/2GtQz4wZtuNNu7zXH5HtV4/3)

## Key findings
- Real-time allocation needs **35% to 50% more storage** than allocating on the previous month-end balance (Feb to Mar 2020).
- Average-balance allocation needs 2% to 10% less than month-end, but is harder to operate.
- Customer data moves to a new node about every **14.6 days**; 95% of moves happen within 28 days, consistent across all 5 regions.
- Only **23.4%** of customers grew their balance by more than 5% over the period; outflows exceed deposits by ~240K.

**Recommendation:** Option 1 (previous month-end balance), unless real-time allocation brings enough customer value to justify the extra storage.

## Data provisioning by option
| Month | Option 1: Month-end | Option 2: Average | Option 3: Real-time |
|---|---|---|---|
| Feb 2020 | 235,595 | 230,257 | 353,655 |
| Mar 2020 | 261,508 | 235,619 | 353,231 |

April is excluded from comparison: data stops on 28 April and only 309 of 500 customers transacted that month.

## Repository
| File | Content |
|---|---|
| `sql/00_explore.sql` | Row counts, date ranges, data quality checks |
| `sql/A_customer_nodes.sql` | Node allocation and reallocation metrics |
| `sql/B_transactions.sql` | Transaction mix, deposits, monthly balances |
| `sql/C_data_allocation.sql` | Running balances and the three provisioning options |
| `assumptions.md` | Every assumption and data quality decision |

## Techniques
CTEs, window functions (running totals with `SUM() OVER`), `PERCENTILE_CONT`, `GENERATE_SERIES` to fill missing months, `LEFT JOIN` + `COALESCE`, conditional aggregation.

## Key data quality decisions
- Excluded 500 placeholder rows (`end_date = 9999-12-31`) from reallocation metrics.
- Negative balances receive 0 storage.
- Months without transactions carry the previous balance forward.
