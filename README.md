# E-Commerce Sales Analysis

End-to-end e-commerce analytics using SQL — revenue trends, 
delivery performance, geographic analysis & customer segmentation

## 🔗 Live Dashboard
[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/shaka.uday/viz/Olist-Ecommerce-Analysis-Shaka-Uday/Olist_Sales_Dashboard)

## Key findings

| Metric                        | Value                          |
|-------------------------------|--------------------------------|
| Total orders                  | 96,461                         |
| Unique customers              | 93,342                         |
| Total revenue                 | R$ 13,219,045                  |
| Avg item price                | R$ 119.98                      |
| Top state by revenue          | São Paulo — R$ 5,065,805 (38%) |
| Normal delivery (8-14 days)   | 39.4% of orders                |
| Fast delivery (1-7 days)      | 31.8% of orders                |
| Very slow delivery (30+ days) | 4.5% of orders                 |
| One-time buyers               | 97% of customers               |

## Key insights

**1 — Geographic concentration is extreme**
São Paulo alone drives 38% of total revenue — 3x more than
Rio de Janeiro (R$1.75M) in second place. Any growth strategy
must prioritise SP infrastructure while developing RJ and MG.

**2 — Retention is the biggest problem**
97% of customers never return for a second order. Only 0.2%
are loyal (3+ orders). This points to a critical gap in
post-purchase engagement and loyalty programmes.

**3 — Delivery speed needs improvement**
28.9% of orders take longer than 15 days. 4.5% take over
30 days. In an era of same-day delivery expectations this
directly drives the low retention rate.

**4 — Revenue grew 7,000x in 14 months**
From R$134 in September 2016 to R$987,648 in November 2017 —
one of the fastest e-commerce growth curves in Latin America.

## Tech stack
`MySQL` `SQL` `Tableau Public` `Excel`

## SQL highlights
- 15 queries across 3 joined tables (96,000+ rows)
- Window functions: LAG, SUM OVER, RANK, NTILE
- CTEs for month-over-month growth calculation
- Delivery performance bucketing with DATEDIFF
- Customer segmentation using CASE + subqueries

## Project structure
