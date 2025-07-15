create database churn_project;
use churn_project;

-- 1. Total Customers & Churn Rate:
with cte as (
select count(*) as total_customers, 
sum(case when Churn  = "Yes" then 1 else 0 end) as churned_customers
from churn_cleaned_data
)
select total_customers, round(churned_customers/total_customers*100,2) as churn_rate
from cte

-- Insight:
-- The overall churn rate gives a high-level view of customer retention performance. Here, if the churn rate is around 26%, 
-- it means over 1 in 4 customers are leaving, which may require immediate attention from the business.


-- 2. Churn Rate by Gender:
select gender, 
count(*) as total, 
sum(churn = 'Yes') as churn, 
round(sum(churn = 'Yes')*100.0/count(*),2) as churn_rate_percent
from churn_cleaned_data
group by gender;

-- Insight:
-- Gender does not significantly influence churn. Both male and female customers tend to churn at similar rates, 
-- indicating that targeting by gender alone may not improve retention.


-- 3. Churn by Contract Type:
select 
    Contract,
    count(*) as total,
    sum(Churn = 'Yes') as churned,
    round(100.0 * sum(Churn = 'Yes') / count(*), 2) as churn_rate_percent
from churn_cleaned_data
group by Contract
order by churn_rate_percent desc;

-- Insight:
-- Customers on Month-to-month contracts have the highest churn rate, while those on One/Two year contracts are more loyal.


-- 4. Average Monthly Charges by Churn Status:
select 
    Churn,
    round(avg(MonthlyCharges), 2) as avg_monthly_charges
from churn_cleaned_data
group by Churn;

-- Insight:
-- Churned customers tend to have higher monthly charges. 
-- This may suggest that pricing or value perception issues could be driving churn among high-paying customers.


-- 5. Tenure Distribution of Churned vs Retained Customers:
select 
    Churn,
    min(tenure) as min_tenure,
    max(tenure) as max_tenure,
    round(avg(tenure), 1) as avg_tenure
from churn_cleaned_data
group by Churn;

-- Insight:
-- Churned customers have significantly lower tenure, indicating that early-stage customers are more likely to leave.


-- 6. Churn by Internet Service Type:
select 
    InternetService,
    count(*) as total,
    sum(Churn = 'Yes') as churned,
    round(100.0 * sum(Churn = 'Yes') / count(*), 2) as churn_rate_percent
from churn_cleaned_data
group by InternetService;

-- Insight:
-- Customers using Fiber optic internet have the highest churn rate, 
-- which could indicate service quality or pricing concerns with that offering.


-- 7. Top 5 Payment Methods by Churn Rate:
select 
    PaymentMethod,
    count(*) as total,
    sum(Churn = 'Yes') as churned,
    round(100.0 * sum(Churn = 'Yes') / count(*), 2) as churn_rate_percent
from churn_cleaned_data
group by PaymentMethod
order by churn_rate_percent desc
limit 5;

-- Insight:
-- Customers paying via Electronic check tend to churn more.


-- 8. Churn by Senior Citizens:
select 
    SeniorCitizen,
    count(*) as total,
    sum(Churn = 'Yes') as churned,
    round(100.0 * sum(Churn = 'Yes') / count(*), 2) as churn_rate_percent
from churn_cleaned_data
group by SeniorCitizen;

-- Insight:
-- Senior citizens show a slightly higher churn rate.


-- 10. Estimated Revenue Lost Due to Churn:
select 
    round(sum(case when Churn = 'Yes' then MonthlyCharges * tenure else 0 end), 2) as estimated_revenue_lost
from churn_cleaned_data;

-- Insight:
-- The estimated total revenue lost from churned customers is 2862576.9 (USD).


-- 11. Most Common Service Combinations Among Churned Customers:
select InternetService, 
       StreamingTV, 
       TechSupport, 
       count(*) as churned_count
from churn_cleaned_data
where Churn = 'Yes'
group by InternetService, StreamingTV, TechSupport
order by churned_count desc
limit 5;

-- Insight:
-- Certain combinations (like Fiber optic + no tech support) might be more vulnerable to churn — target these with bundle offers.


-- 12. Churn Likelihood by Tenure Deciles:
with cte as (
  select *,
         ntile(10) over (order by tenure) as tenure_decile
  from churn_cleaned_data
)
select tenure_decile,
       count(*) as total,
       sum(Churn = 'Yes') as churned,
       round(100.0 * sum(Churn = 'Yes') / count(*), 2) as churn_rate_percent
from cte
group by tenure_decile
order by churn_rate_percent desc;

-- Insight:
-- Churn is usually heaviest in the lowest deciles (first few months). Knowing this helps build targeted early lifecycle interventions.


-- 13. Rank Customers by Total Spend (Revenue):
select customerID, 
       round(MonthlyCharges * tenure, 2) as total_revenue,
       rank() over (order by MonthlyCharges * tenure desc) as revenue_rank
from churn_cleaned_data
limit 10;

-- Insight:
-- Top revenue-generating customers can be prioritized for retention efforts and loyalty programs.
