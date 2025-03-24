-- Walmart Project Queries - MySQL

SELECT * FROM walmart_db.walmart;

-- Count total invoice_id records
SELECT COUNT(INVOICE_ID) FROM WALMART_DB.WALMART; 

-- Count payment methods and number of transactions by payment method
SELECT COUNT(*) AS TOTAL_COUNT, PAYMENT_METHOD  FROM walmart_db.walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT(BRANCH)) AS TOTAL_UNIQUE FROM walmart_db.walmart;

-- Find the minimum quantity sold
SELECT MIN(QUANTITY) FROM walmart_db.walmart;

-- Businees problems

/*Q.1. Find the different payment method and number of transactions of qty sold */
SELECT PAYMENT_METHOD,COUNT(*) AS NO_PAYMENT ,SUM(QUANTITY) AS NO_QYT_SOLD  FROM walmart_db.walmart
GROUP BY payment_method;

/* Project questions # 2
Identify the highest radet category in each branch ,displaying branch category 
sum rating */
SELECT * FROM 
(SELECT BRANCH, CATEGORY,AVG(RATING) AS AVG_RATING ,
RANK() OVER(PARTITION BY Branch ORDER BY  AVG(RATING)DESC)AS RANK_NU
FROM walmart_db.walmart
GROUP BY 1,2
)RANK_NU;

-- Q3: Identify the busiest day for each branch based on the number of transactions
select * from 
(
SELECT 
    Branch, 
    DATE_FORMAT(DATE, '%d/%m/%y') AS FORMATTED_DATE, 
    DAYNAME(DATE) AS DAY_NAME,
    COUNT(*) AS no_transactions,
    rank() over(partition by branch order by count(*) desc) as rank_nu
FROM walmart_db.walmart
GROUP BY Branch, FORMATTED_DATE, DAY_NAME
ORDER BY Branch, no_transactions DESC
) rank_nu
where rank_nu =1;


-- Q4: Calculate the total quantity of items sold per payment method
SELECT PAYMENT_METHOD, SUM(QUANTITY) AS NUM_QUANTITY_SOLD from walmart_db.walmart
GROUP BY PAYMENT_METHOD;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT CITY ,CATEGORY, 
MIN(RATING) AS MIN_RATING,
MAX(RATING) AS MAX_RATING,
AVG(RATING) AS AVG_RATING
FROM walmart_db.walmart
GROUP BY 1,2;

-- Q6: Calculate the total profit for each category
SELECT CATEGORY,
SUM(TOTAL) AS TOTAL_REVENUE,
SUM(total+profit_margin)  as profit FROM walmart_db.walmart
GROUP BY CATEGORY;
SELECT * FROM walmart_db.walmart;

-- Q7: Determine the most common payment method for each branch
WITH CTE AS(
SELECT BRANCH, PAYMENT_METHOD ,
COUNT(*) AS TOTAL_TRANSACTIONS,
RANK() OVER (PARTITION BY BRANCH ORDER BY COUNT(*) DESC)AS RANK_NU
FROM walmart_db.walmart
GROUP BY 1,2
)
SELECT * FROM CTE
WHERE RANK_NU =1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
		Branch,
    CASE 
        WHEN EXTRACT(HOUR FROM TIME) < 12 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS DAY_TIME,
    COUNT(*) AS TOTAL_COUNT
FROM walmart_db.walmart
GROUP BY 1,2
ORDER BY 1,2 DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH REVENUE AS (
    SELECT BRANCH, SUM(TOTAL) AS REVENUE_2022
    FROM walmart_db.walmart
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(DATE, '%d/%m/%y')) = 2022
    GROUP BY BRANCH
),
REVENUE_2023 AS (
    SELECT BRANCH, SUM(TOTAL) AS REVENUE_2023
    FROM walmart_db.walmart
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(DATE, '%d/%m/%y')) = 2023
    GROUP BY BRANCH
)
SELECT 
    COALESCE(R1.BRANCH, R2.BRANCH) AS BRANCH, 
    COALESCE(R1.REVENUE_2022, 0) AS REVENUE_2022, 
    COALESCE(R2.REVENUE_2023, 0) AS REVENUE_2023
FROM REVENUE R1
JOIN REVENUE_2023 R2 ON R1.BRANCH = R2.BRANCH;
