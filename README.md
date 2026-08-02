# Bank-Transaction-Data-Analysis

#### SQL, PostgreSQL
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




