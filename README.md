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

