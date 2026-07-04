/* ============================================================
   BANK CUSTOMER CHURN ANALYSIS
   ============================================================
   Dataset: dbo.output (It includes a bank's customer records, 
		one-hot encoded country columns, churn flag)
   Goal: Churn analysis based on various factors        
   ============================================================= */
 
-- Creating a database
-- CREATE DATABASE bank_churn;

USE bank_churn;

/*============================================================= 

	Fixing errors of the dataset 
============================================================= */


-- This is to view the datatypes and description of the table 

--EXEC sp_help '[dbo].[output]';

--Changning the datatype of columns, as all had the same datatype, varchar

/*ALTER TABLE [dbo].[output]
ALTER COLUMN age int NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN balance float NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN credit_score float NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN tenure float NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN balance float NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN products_number int NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN credit_card int NOT NULL;

ALTER TABLE [dbo].[output]
ALTER COLUMN estimated_salary float NOT NULL;

EXEC sp_help '[dbo].[output]';

--To add customer id in table
--ALTER TABLE [dbo].[output]
--ADD customer_id int identity(1,1); */


/*=========================================================================================
 

	QUESTION 1: WHAT IS THE AVERAGE AGE, CREDIT SCORE AND TENURE OF OUR CUSTOMERS

===========================================================================================*/


WITH average_cte AS 
( SELECT (SELECT AVG(age) FROM [dbo].[output]) AS AVERAGEAGE,
(SELECT AVG(credit_score) FROM [dbo].[output]) AS AVERAGECREDITSCORE, 
(SELECT AVG(tenure) FROM [dbo].[output]) AS AVERAGETENURE,
(SELECT AVG(estimated_salary) FROM [dbo].[output]) AS ESTIMATEDSALARY ) 

select * from average_cte;

--Answer: 
--AVERAGEAGE 	AVERAGECREDITSCORE	AVERAGETENURE  ESTIMATEDSALARY
--38	             650.5288	      5.0128              100090.239881

/*========================================================================================

 QUESTION 2: count of churn that shows by age and gender (which get churned the most)

=========================================================================================*/

WITH ACTIVE_MEMBER_CHURN AS (
    SELECT 
        age,churn,
         CASE 
            WHEN gender_Male = 'TRUE' THEN 'Male'
            WHEN gender_Female = 'TRUE' THEN 'Female'
            ELSE 'Unknown'
        END AS Gender,

        
        CASE 
            WHEN country_France = 'TRUE' THEN 'France'
            WHEN country_Germany = 'TRUE' THEN 'Germany'
            WHEN country_Spain = 'TRUE' THEN 'Spain'
        END AS country,

        CASE
            WHEN age >= 18 AND age <= 25 THEN '18-25' 
            WHEN age BETWEEN 26 AND 34 THEN '26-34'
            WHEN age BETWEEN 35 AND 54 THEN '35-54'
            ELSE '55 and Older'
        END AS AGE1
    FROM [dbo].[output]
)
SELECT 
    AGE1,Gender,country,
    COUNT(*) AS [churn]
FROM ACTIVE_MEMBER_CHURN
WHERE churn = 1
GROUP BY AGE1,Gender,country
ORDER BY [churn] desc;

       /*=========================================================================================
 

	QUESTION 3: What is the churn rate (Overall and based on each country)


	=======================================================================================*/

    -- Total Churn Rate
WITH ChurnRateOverall AS
(
SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM [dbo].[output] ) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM [dbo].[output]
WHERE churn = 1) AS Churned
)

select * from  ChurnRateOverall;

-- Answer: TotalNumerOfCustomers     TotalNumberOfChurnedCustomers   ChurnRate
--            10000	                            2037	               20.37    


-- For Churn rate based on Country

WITH customer_churn AS (
    SELECT 
        CAST(churn AS INT) AS churn,
        CASE 
            WHEN country_France = 'TRUE' THEN 'France'
            WHEN country_Germany = 'TRUE' THEN 'Germany'
            WHEN country_Spain = 'TRUE' THEN 'Spain'
        END AS country
    FROM [dbo].[output]     
)
SELECT 
    country,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS churn_rate
FROM customer_churn
GROUP BY country;

-- Answer: Country  TotalNumerOfCustomers     TotalNumberOfChurnedCustomers   ChurnRate
           --Spain	        2477	                     413	               16.67
           --France	        5014	                     810	               16.15
           --Germany	    2509	                     814	               32.44



     /*=========================================================================================
 

	QUESTION 4:HOW MANY OF OUR CUSTOMERS ARE ACTIVE? ( 0 MEANS NO AS IN THEY ARE NOT ACTIVE)


	========================================================================================*/
    
    -- For country wise analysis of inactive customer vs churn

WITH ACTIVE_MEMBER_CHURN AS (
    SELECT 
    active_member,
        CAST(churn AS INT) AS churn,
        CASE 
            WHEN country_France = 'TRUE' THEN 'France'
            WHEN country_Germany = 'TRUE' THEN 'Germany'
            WHEN country_Spain = 'TRUE' THEN 'Spain'
        END AS country
    FROM [dbo].[output]     
)
SELECT 
    country,
    COUNT(*) as 'active members per country'
    FROM ACTIVE_MEMBER_CHURN
    Where active_member=1
    GROUP BY country


--For overall analysis of overall inactivity vs churn rate 
SELECT
(SELECT COUNT(*) FROM [dbo].[output] WHERE active_member=0 and churn=1) AS 'overall churn of inactive members'; 


      /*===========================================================================================
 

	QUESTION 5: Comparison of tenure between churned and non- churned members

	=========================================================================================*/


SELECT AVG(tenure) FROM [dbo].[output] where churn=1;
SELECT AVG(tenure) FROM [dbo].[output] where churn=0;


       /*========================================================================================
 

		QUESTION 6: Comparison of members that are inactive and whether they have been 				churned or not

	========================================================================================*/

SELECT
(SELECT COUNT(*) FROM [dbo].[output] WHERE active_member=0 and churn=1) AS 'overall churn of inactive members'; 

SELECT
(SELECT COUNT(*) FROM [dbo].[output] WHERE active_member=0 and churn=0) AS 'inactive members that havent churned'; 
    

	/*=================================================================================

	QUESTION 7: How many of our customers own credit cards according to their age?
	
	This question is asked know the age distribution of credit card owners and what kind of 	deals to target for that specific age group
        =================================================================================*/

SELECT age,COUNT(credit_card) AS [credit card owners]
FROM [dbo].[output]
group by age
HAVING COUNT(credit_card) > 1
ORDER BY [age] ASC;

	

	/*=========================================================================================
 

	QUESTION 8: What is the average salary of our customers and what is the average salary per 	country?

	 This question is asked, so that we know quality of our customers and what kind of services they may expect from our bank
	=========================================================================================*/

-- Overall average salary
SELECT AVG(estimated_salary) 
FROM [dbo].[output];

--Answer: 100090.239881

-- Average salary as per country 

WITH customer_churn AS (
    SELECT 
    estimated_salary,
        CAST(churn AS INT) AS churn,
        CASE 
            WHEN country_France = 'TRUE' THEN 'France'
            WHEN country_Germany = 'TRUE' THEN 'Germany'
            WHEN country_Spain = 'TRUE' THEN 'Spain'
        END AS country
    FROM [dbo].[output]     
)
SELECT 
    country,
    AVG(estimated_salary) as 'average salary per country'
    FROM customer_churn
    GROUP BY country;

    --Answer: Spain	99440.572280985
           --France	99899.1808137217
           --Germany 101113.435101634


	/*========================================================================================
 

	QUESTION 9: How many of our customers own credit cards according to their age and their 	respective credit score?

	========================================================================================*/

SELECT age,credit_score,COUNT(credit_card) AS [credit card owners]
FROM [dbo].[output]
group by age,credit_score
HAVING COUNT(credit_card) > 1;