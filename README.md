# Bank-Transaction-Data-Analysis

#### SQL, PostgreSQL, VS Code
## 📊 Dataset

The dataset used in this project was downloaded from Kaggle:
[Bank Customer Segmentation](https://www.kaggle.com/datasets/shivamb/bank-customer-segmentation).
The dataset contains 1 million+ transactions of over 800,000 bank customers in India.

***

## 💡 Analysis

### 1. How large is the customer base, and what is the overall transaction activity?
```sql
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(transaction_id) AS total_transactions,
    SUM(transaction_amount) AS total_transaction_amount,
    MAX(transaction_amount) AS max_transaction_amount,
    MIN(transaction_amount) AS min_transaction_amount,
    AVG(transaction_amount) AS avg_transaction_amount
FROM public.bank_transactions;
```
**Output**

<img width="900" alt="image" src="https://github.com/branmoonsan/Bank-Transaction-Data-Analysis/blob/main/img/Screenshot%202026-08-02%20at%2016.00.32.png">

There are over 880k customers and over 1 mil transactions.

***

### 2. Which customer segments perform the most transactions? (Gender & Age Group)

```sql
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
```
**Output**

<img width="500" alt="image" src="https://github.com/branmoonsan/Bank-Transaction-Data-Analysis/blob/main/img/Screenshot%202026-08-02%20at%2017.02.24.png">

Male customers aged 36-45 have the highest number of transactions, followed by male customers aged 26-35 and female customers aged 36-45.

***

### 3. Which cities have the highest banking activity?
```sql
SELECT
    customer_location AS city,
    COUNT(*) AS no_of_transaction,
    SUM(transaction_amount) AS total_transaction_amount
FROM public.bank_transactions
WHERE customer_location IS NOT NULL
GROUP BY customer_location
ORDER BY no_of_transaction DESC
LIMIT 5;
```
**Output**

<img width="500" alt="image" src="https://github.com/branmoonsan/Bank-Transaction-Data-Analysis/blob/main/img/Screenshot%202026-08-02%20at%2017.59.23.png">

Mumbai, New Delhi and Bangalore are the top three cities with the highest banking activity by both number of transactions and total transaction volume.

***

### 4. How does transaction activity change over time? (Monthly Trend)
```sql
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
```
**Output**

<img width="600" alt="image" src="https://github.com/branmoonsan/Bank-Transaction-Data-Analysis/blob/main/img/Screenshot%202026-08-02%20at%2022.33.56.png">

August recorded the highest transaction volume, exceeding 1 billion. In September, transaction volume declined by 40.57% month-over-month, falling to approximately 600 million. The downward trend continued in October, with transaction volume decreasing by a further 98.75% compared with the previous month. Overall, we can see a significant downtrend in transaction activity.

***

### 5. When are customers most active? (Hour of Day Analysis)
```sql
SELECT
    EXTRACT (HOUR FROM transaction_time) as transaction_hour,
    COUNT(*) AS transaction_count
FROM
    public.bank_transactions
GROUP BY
    transaction_hour
ORDER BY
    transaction_count DESC;
```
**Output**

<img width="400" alt="image" src="https://github.com/branmoonsan/Bank-Transaction-Data-Analysis/blob/main/img/Screenshot%202026-08-02%20at%2023.05.06.png">

Customer transaction activity was highest during the afternoon and evening, with peak transactions between 6:00 PM and 10:00 PM. This means that customers are more likely to conduct transactions after lunchtime and throughout the evening.

***

