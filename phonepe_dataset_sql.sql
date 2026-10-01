use phonepe;
select *from phonepe_dataset;
-- total dataset
select count(*)from phonepe_dataset;
-- Which merchant category has the highest number of transactions?

select Merchant_Name,floor(sum(Amount_INR)) as heighest_transation
from phonepe_dataset
group by merchant_name
order by heighest_transation desc limit 1;

-- Find the top 3 cities with the most UPI transactions.

select city,floor(sum(Amount_INR)) as heighest_transation
from phonepe_dataset
group by city
order by heighest_transation desc limit 3;

-- Calculate the total cashback earned per bank.

select Bank_Name,floor(sum(Amount_INR)) as total_cashback
from phonepe_dataset
group by bank_name
order by total_cashback desc;

                                  #Fraud & Risk Analysis
                                  
-- Find all transactions flagged as suspected fraud with their bank, UPI app, and risk score.

select bank_name,upi_app,sum(risk_score) as total_risk_score,count(is_suspected_fraud) as total_count
from phonepe_dataset
where is_suspected_fraud ='yes'
group by bank_name,upi_app 
order by total_risk_score desc;

-- Calculate the average risk score per device OS (Android vs iOS)

select device_os,floor(avg(risk_score)) as total_risk_score
from phonepe_dataset
group by device_os
order by total_risk_score desc;

-- Identify banks with the highest number of suspected fraud cases.

select bank_name,count(is_suspected_fraud) as total
from phonepe_dataset
where is_suspected_fraud ='yes'
group by bank_name
order by total desc limit 1;

-- Show the top 5 transactions with the highest risk scores.

select *
from phonepe_dataset 
order by risk_score desc limit 5;

-- Compare average transaction amounts between suspected fraud vs non-fraud transactions.

(select 'fraud' as type_of ,avg(amount_inr) as avg_
from phonepe_dataset
where is_suspected_fraud='yes') 
union  all
(select  'secured'as type_of ,avg(amount_inr) as avg_
from phonepe_dataset
where is_suspected_fraud='no') ;

-- Find the top 3 states with the highest number of UPI transactions.

select state,floor(sum(amount_inr)) as total_amount
from phonepe_dataset
group by state
order by total_amount desc limit 3;

-- Show the merchant categories with more than 2 transactions.

select merchant_category
from phonepe_dataset
group by merchant_category
having count(*) > 2;

-- List all transactions where the transaction fee > 0.

select *
from phonepe_dataset
where transaction_fee_inr >0;

-- Retrieve the count of transactions by payment mode (Bank Account, UPI ID, QR Scan).

select count(*) as Total_transaction_by
from phonepe_dataset
where payment_mode in ('Bank Account', 'UPI ID', 'QR Scan');

-- Write a query to find the bank with the highest average transaction amount.

select bank_name, floor(avg(amount_inr)) as highest_avg_trans
from phonepe_dataset
group by bank_name
order by highest_avg_trans desc limit 1;

-- Identify the age group and gender combination that spends the most on Food & Dining.

select gender, floor(sum(amount_inr)) as total_amount_spend
from phonepe_dataset
where merchant_category ='food & dining'
group by gender
order by total_amount_spend desc;

-- Find the failure reasons (if any) and count how many times each occurred.

select failure_reason,count(*) as failed
from phonepe_dataset
where failure_reason is not null
group by failure_reason 
order by failed ;

-- Show the merchant with the maximum number of unique customers.

select merchant_name,count(distinct(customer_id)) as maxmimum_order
from phonepe_dataset
group by merchant_name
order by maxmimum_order desc;

-- Rank banks by their fraud suspicion rate

with cte_fraud as (select count(is_suspected_fraud) as fraud
from phonepe_dataset
where is_suspected_fraud='yes') 
select bank_name,count(is_suspected_fraud) as total
from cte_fraud
group by bank_name;

-- Find the highest 2 transactions per Bank_Name based on Amount_INR.

SELECT Bank_Name,
       Amount_INR,
       dense_rank()  OVER (
           PARTITION BY Bank_Name 
           ORDER BY Amount_INR DESC
       ) 
FROM phonepe_dataset
WHERE total <= 2;

-- Create a CTE that filters transactions from the Transactions table where Merchant_Category = 'Fuel'.
-- From that CTE, count the number of transactions per City.

WITH CustomerCounts AS (
    SELECT Customer_ID, COUNT(*) AS Total_Transactions
    FROM phonepe_dataset
    GROUP BY Customer_ID
)
SELECT Customer_ID, Total_Transactions
FROM CustomerCounts
WHERE Total_Transactions > 2;

-- Most transaction amount higher than avgerage amount

select upi_app,round(sum(amount_inr)) as Higher
from phonepe_dataset
group by upi_app
having sum(amount_inr) >
(select avg(higher)
from 
(select upi_app,sum(amount_inr) as higher
from phonepe_dataset
group by upi_app )as a);

-- find the merchant name with the higher than avg number of transactions. 

select merchant_name,count(amount_inr) as total_no_transaction
from phonepe_dataset
group by merchant_name
having count(amount_inr) >
(select avg(total_no_transaction)
from 
(select merchant_name,count(amount_inr) as total_no_transaction
from phonepe_dataset
group by merchant_name) as a);

/*  Retrieve customer IDs whose transactions were processed by banks with
 a risk score greater than the average risk score of all Android transactions.*/   

select bank_name,sum(risk_score) as higher_than_avg
from phonepe_dataset
group by bank_name
having sum(risk_score) >
(select avg(higher_than_avg)
from
(select bank_name,sum(risk_score) as higher_than_avg
from phonepe_dataset
group by bank_name)as a );

/*Find all customers who made a transaction in the Healthcare category,
 but only if their bank transaction record shows Is_Suspected_Fraud = 'Yes'.*/
 
 select customer_id,count(*) as total
 from phonepe_dataset
 where merchant_category ='healthcare' and Is_Suspected_Fraud = 'Yes'
 group by customer_id;
 
 -- Write a query to identify customers who used more than one UPI_App.
 
select customer_id, count(upi_app) as total_transaction
 from phonepe_dataset
group by customer_id
 having count(upi_app)>1;
 
/* Identify customers who made transactions in multiple merchant categories 
and list those categories.*/
 
SELECT Customer_ID,
GROUP_CONCAT(DISTINCT Merchant_Category ORDER BY Merchant_Category SEPARATOR ', ') AS Categories
FROM phonepe_dataset
GROUP BY Customer_ID
HAVING COUNT(DISTINCT Merchant_Category) > 1;

/*Build a query to calculate average transaction amount per gender per city, 
and sort by highest spenders.*/

select  gender,city,round(avg(amount_inr)) as Avg_amount
from phonepe_dataset
group by gender,city
order by Avg_amount desc;

-- Compare Android vs iOS in terms of average cashback per transaction.

(select device_os,round(avg(amount_inr)) as avg_amount
from phonepe_dataset
where device_os='android')
union all
(select device_os,round(avg(amount_inr)) as avg_amount
from phonepe_dataset
where device_os='IOS');

-- Find the most common payment mode used by customers in each state.

select state,payment_mode
from (select state,payment_mode,
count(*) as most_common,
rank() over(partition by state order by count(*) desc) as  rnk
from phonepe_dataset
group by state,payment_mode) as rank_mode
where rnk=1;





/*Write a query to find the most frequently used UPI app by customers aged 25–34, 
and calculate its percentage share of total transactions.*/

with cte as (select upi_app,count(*) as total 
from phonepe_dataset
where age_group ='25-34'
group by upi_app
 )
select upi_app,total,(count(*)/sum(total))*100 as percentage
from cte
group by upi_app
order by total desc ;

-- Most Common Merchant Category per Age Group

select Merchant_category,age_group
from (select Merchant_category,age_group,
count(*) as most_common,
rank() over(partition by age_group order by count(*) desc) as rnk
from phonepe_dataset
group by merchant_category,age_group) as rnked
where rnk=1;

-- alternate technique

select Merchant_category,age_group,
count(*) as most_common,
rank() over(partition by age_group order by count(*) desc) as rnk
from phonepe_dataset
group by merchant_category,age_group 
order by rnk desc limit 1;

-- Highest Risk Score Transaction per Device OS

select upi_app, device_os
from(select upi_app, device_os,
sum(risk_score) as total_risk,
rank() over (partition by device_os order by sum(risk_score) desc) as rnk
from phonepe_dataset
group by device_os,upi_app) as rnked
where rnk=1;



