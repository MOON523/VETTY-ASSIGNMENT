CREATE DATABASE VETTY_ASSIGNMENT;
USE VETTY_ASSIGNMENT;
CREATE TABLE transactions (
  buyer_id INT,
  purchase_time TIMESTAMP,
  refund_time TIMESTAMP,
  refund_item VARCHAR(10),
  store_id VARCHAR(10),
  item_id VARCHAR(10),
  gross_transaction_value INT
);
INSERT INTO transactions VALUES
(3, '2019-09-19 21:19:06', NULL, NULL, 'a', 'a1', 58),
(12,'2019-12-10 20:10:14','2019-12-15 23:19:06','b2','b','b2',475),
(3,'2020-09-01 23:59:46','2020-09-02 21:22:06','d2','d','d3',2500),
(8,'2020-04-30 20:21:56',NULL,NULL,'f','f2',91),
(8,'2020-04-06 21:00:22',NULL,NULL,'e','e7',24),
(3,'2019-09-23 12:09:35','2019-09-27 02:55:02','g6','g','g6',61);

CREATE TABLE items (
  store_id VARCHAR(10),
  item_id VARCHAR(10),
  item_category VARCHAR(50),
  item_name VARCHAR(50)
);

INSERT INTO items VALUES
('a','a1','pants','denim pants'),
('a','a2','tops','blouse'),
('f','f1','table','coffee table'),
('f','f2','chair','lounge chair'),
('d','d6','chair','armchair'),
('b','b2','jewelry','bracelet'),
('b','b4','earphone','airpods');

-- Q1

SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m-01') AS month_start,   -- First day of that month
    COUNT(*) AS total_purchases                              -- Count non-refunded purchases
FROM transactions
WHERE refund_time IS NULL                                    -- Exclude refunded
GROUP BY DATE_FORMAT(purchase_time, '%Y-%m-01')
ORDER BY month_start;

-- Q2

/* Q2: How many stores receive at least 5 orders/transactions in October 2020? */

SELECT COUNT(*) AS store_count
FROM (
    SELECT 
        store_id
    FROM transactions
    WHERE purchase_time >= '2020-10-01'      -- Start of October 2020
      AND purchase_time <  '2020-11-01'      -- Start of November 2020
    GROUP BY store_id
    HAVING COUNT(*) >= 5                     -- At least 5 orders per store
) AS t;

-- Q3

SELECT 
    store_id,
    MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_time)) AS min_refund_interval_minutes
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id;

-- Q4
WITH first_order AS (
    SELECT 
        store_id,
        gross_transaction_value,
        ROW_NUMBER() OVER (PARTITION BY store_id 
                           ORDER BY purchase_time) AS rn   -- Rank orders by earliest time
    FROM transactions
)
SELECT store_id, gross_transaction_value
FROM first_order
WHERE rn = 1;                                          -- Return only the FIRST order per store

-- Q5
WITH first_purchase AS (
    SELECT 
        buyer_id,
        item_id,
        ROW_NUMBER() OVER (PARTITION BY buyer_id 
                           ORDER BY purchase_time) AS rn   -- First purchase per buyer
    FROM transactions
)
SELECT 
    i.item_name,                                       -- Item name from items table
    COUNT(*) AS times_ordered                          -- Count how many buyers bought it first
FROM first_purchase fp
JOIN items i ON fp.item_id = i.item_id                 -- Match item info
WHERE rn = 1                                           -- Only first purchase
GROUP BY i.item_name                                   -- Group by item name
ORDER BY times_ordered DESC                            -- Most popular item first
LIMIT 1;                                               -- Top 1 most popular item

-- Q6

SELECT 
    *,
    CASE 
        WHEN refund_time IS NOT NULL
             AND TIMESTAMPDIFF(HOUR, purchase_time, refund_time) <= 72
        THEN 1
        ELSE 0
    END AS refund_process_flag
FROM transactions;

-- Q7
WITH ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY buyer_id 
                           ORDER BY purchase_time) AS rn   -- Ranking purchases per buyer
    FROM transactions
    WHERE refund_time IS NULL                             -- Ignore refunded purchases
)
SELECT *
FROM ranked
WHERE rn = 2;                                             -- Only second purchase per buyer

-- Q8
WITH ranked AS (
    SELECT 
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id 
                           ORDER BY purchase_time) AS rn   -- Ranking automatically finds 2nd
    FROM transactions
)
SELECT buyer_id, purchase_time
FROM ranked
WHERE rn = 2;                                             -- Return only second transaction










