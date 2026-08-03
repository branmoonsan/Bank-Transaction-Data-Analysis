--Create Table
CREATE TABLE public.bank_transactions
(
    transaction_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(20),
    customer_dob TEXT,
    customer_gender CHAR(1),
    customer_location VARCHAR(100),
    account_balance NUMERIC(15, 2),
    transaction_date TEXT,
    transaction_time TEXT,
    transaction_amount NUMERIC(15, 2)

);


--Load CSV file into the table
COPY public.bank_transactions
FROM '/Users/Shared/Data_Analysis/Bank_Transaction_Analysis/bank_transactions.csv'
DELIMITER ',' CSV HEADER;

SELECT *
FROM public.bank_transactions
LIMIT 10;

--Alter customer_dob data type to DATE format
ALTER TABLE public.bank_transactions
ALTER COLUMN customer_dob
TYPE DATE
USING (
    CASE
        WHEN lower(trim(customer_dob)) = 'nan' THEN NULL
        WHEN trim(customer_dob) = '1/1/1800' THEN NULL
        ELSE to_date(
            lpad(split_part(customer_dob, '/', 1), 2, '0') || '/' ||
            lpad(split_part(customer_dob, '/', 2), 2, '0') || '/' ||
            right(split_part(customer_dob, '/', 3), 2),
            'DD/MM/YY'
        )
    END
);


--Converting the transaction_time from INTEGER to TIME format
ALTER TABLE public.bank_transactions
ALTER COLUMN transaction_time
TYPE TIME
USING (
    to_timestamp(
        lpad(transaction_time, 6, '0'),
        'HH24MISS'
    )::time
);

--Q1. How large is the customer base, and what is the overall transaction activity?
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(transaction_id) AS total_transactions,
    SUM(transaction_amount) AS total_transaction_amount,
    MAX(transaction_amount) AS max_transaction_amount,
    MIN(transaction_amount) AS min_transaction_amount,
    ROUND (AVG(transaction_amount), 2) AS avg_transaction_amount
FROM public.bank_transactions;


--Q2. Which customer segments perform the most transactions? (Gender & Age Group)
--Add and calcuate customer_age column
ALTER TABLE public.bank_transactions
ADD COLUMN customer_age INT;

UPDATE public.bank_transactions
SET customer_age =
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, customer_dob));

--Analyse by customer segmentations
SELECT
    age_group,
    customer_gender,
    COUNT(*) AS no_of_transaction
FROM (
    SELECT *,
    CASE
        WHEN customer_age < 18 THEN 'Under 18'
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN customer_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN customer_age BETWEEN 56 AND 65 THEN '56-65'
        ELSE 'Over 65'
    END AS age_group
    FROM public.bank_transactions
) AS age_groups
WHERE
    customer_age IS NOT NULL AND
    customer_gender IN ('M', 'F')
GROUP BY
    age_group,
    customer_gender
ORDER BY
    no_of_transaction DESC
LIMIT 3;



--Q3.Which cities have the highest banking activity?
SELECT
    customer_location AS city,
    COUNT(*) AS no_of_transaction,
    SUM(transaction_amount) AS total_transaction_amount
FROM public.bank_transactions
WHERE customer_location IS NOT NULL
GROUP BY customer_location
ORDER BY no_of_transaction DESC
LIMIT 5;


--Q4.How does transaction activity change over time? (Monthly Trend)
--Use CTE to compute monthly transactions table.
WITH monthly_transactions AS(
    SELECT
        EXTRACT(MONTH FROM TO_DATE(transaction_date, 'DD/MM/YY')) AS month,
        SUM(transaction_amount) AS total_transaction_volume
    FROM
        public.bank_transactions
    GROUP BY
        month
)

SELECT
    month,
    total_transaction_volume,
    ROUND(
        (
            total_transaction_volume 
            - LAG(total_transaction_volume) OVER (ORDER BY month) 
        )* 100
        / LAG(total_transaction_volume) OVER (ORDER BY month), 
        2
    ) AS growth_percentage
FROM monthly_transactions
ORDER BY month;


--Q5.When are customers most active? (Hour of Day Analysis)
SELECT
    EXTRACT (HOUR FROM transaction_time) as transaction_hour,
    COUNT(*) AS transaction_count
FROM
    public.bank_transactions
GROUP BY
    transaction_hour
ORDER BY
    transaction_count DESC;