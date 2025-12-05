# SQL Project – Database Scripts & Analysis

This repository contains SQL scripts used for data analysis, database creation, and query optimization.  
It is structured to help users understand the database workflow, run queries easily, and reproduce the analysis.

Assumptions taken before writing the query.
  1. A purchase is considered refunded only when refund_time IS NOT NULL.
   2. Month of purchase is extracted using DATE_TRUNC on purchase_time.
   3. First order per store = earliest purchase_time.
   4. First purchase per buyer = earliest purchase_time.
   5. Refund interval = refund_time - purchase_time (in minutes).
   6. Refund eligible only if refund occurs within 72 hours.
