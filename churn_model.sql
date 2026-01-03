#Check schema
PRAGMA table_info(churn);

#Count customers
SELECT COUNT(DISTINCT customerID) AS total_customers
FROM churn;

#Churn distribution
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM churn), 2) AS percentage
FROM churn
GROUP BY Churn;

#Churn by contract type
SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY Contract;

#Churn by tenure bucket
SELECT
    CASE
        WHEN tenure < 6 THEN '0–6 months'
        WHEN tenure < 12 THEN '6–12 months'
        WHEN tenure < 24 THEN '12–24 months'
        ELSE '24+ months'
    END AS tenure_group,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY tenure_group
ORDER BY churn_rate DESC;

#Monthly charges vs churn
SELECT
    CASE
        WHEN MonthlyCharges < 50 THEN 'Low'
        WHEN MonthlyCharges BETWEEN 50 AND 80 THEN 'Medium'
        ELSE 'High'
    END AS charge_band,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY charge_band;

#Payment method impact
SELECT
    PaymentMethod,
    COUNT(*) AS customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;

#Auto-pay vs manual
SELECT
    CASE
        WHEN PaymentMethod LIKE '%automatic%' THEN 'Auto Pay'
        ELSE 'Manual Pay'
    END AS payment_type,
    COUNT(*) AS customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY payment_type;

#Internet service vs churn
SELECT
    InternetService,
    COUNT(*) AS customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM churn
GROUP BY InternetService;

#FEATURE TABLE
CREATE TABLE churn_sql_features AS
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    TotalCharges,
    CASE WHEN tenure < 6 THEN 1 ELSE 0 END AS short_tenure_flag,
    CASE WHEN MonthlyCharges > 80 THEN 1 ELSE 0 END AS high_charge_flag,
    CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END AS month_to_month_flag,
    CASE WHEN PaymentMethod LIKE '%automatic%' THEN 0 ELSE 1 END AS manual_payment_flag,
    Churn
FROM churn;

#HIGH-RISK CUSTOMER IDENTIFICATION
SELECT
    COUNT(*) AS high_risk_customers
FROM churn_sql_features
WHERE
    short_tenure_flag = 1
    AND high_charge_flag = 1
    AND Churn = 'Yes';


