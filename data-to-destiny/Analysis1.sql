#TOTAL VISITORS APRIL_DATA
SELECT 
	* 
FROM 
	april_data;
    
#DATA CLEANING - Remove NULL Values and Empty Values from the Dataset
DELETE
FROM
	april_data
WHERE
	CourseID IS NULL AND CourseID='';



#VISITDATE<=APRIL 14 AND STATUS IS ENROLLED
SELECT 
	* 
FROM 
	april_data 
WHERE 
	DATE(VisitDate)<='2023-04-14' and Status='Enrolled';


#WEBSITE TRAFFIC
-- DAILY UNIQUE VISITORS ON EACH PAGE AND AVG TIME SPENT PER VISITOR ON EACH PAGE
SELECT 
	monthname(VisitDate) AS Month,
    date(Visitdate) AS Date,
	'Home' AS Page,
	COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_time 
FROM 
	april_data 
WHERE 
	CourseID='S1B1' AND date(VisitDate)<='2023-04-14' 
AND 
	VisitedPages LIKE '%''Home''%'
GROUP BY
	VisitDate

UNION ALL

SELECT 
	monthname(VisitDate) AS Month,
    date(Visitdate) AS Date,
	'Register Button' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_time 
FROM 
	april_data 
WHERE 
	CourseID='S1B1' AND DATE(VisitDate)<='2023-04-14' 
AND 
	VisitedPages LIKE '%''Register Button''%'
GROUP BY
	VisitDate

UNION ALL

SELECT 
	monthname(VisitDate) AS Month,
    date(Visitdate) AS Date,
	'Payment Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_time 
FROM 
	april_data 
WHERE 
	CourseID='S1B1' AND DATE(VisitDate)<='2023-04-14' 
AND 
	VisitedPages LIKE '%''Payment Page''%'
GROUP BY
	VisitDate

UNION ALL

SELECT 
	monthname(VisitDate) AS Month,
    date(Visitdate) AS Date,
	'Payment Success' AS Page,
	COUNT(DISTINCT VisitorID) AS Count,
	AVG(TimeSpent) AS Avg_time 
FROM 
	april_data 
WHERE 
	CourseID='S1B1' AND DATE(VisitDate)<='2023-04-14' 
AND 
	VisitedPages LIKE '%''Payment Success''%'
GROUP BY
	VisitDate;


#REGISTRATION DATA
-- TOTAL NUMBER OF REGISTRATION ALONG WITH DAILY REGISTRATION TRENDS
WITH Reg_count AS (
    SELECT 
        VisitDate,
        COUNT(*) AS Daily_reg,
        SUM(COUNT(*)) OVER (PARTITION BY MONTH(VisitDate) ORDER BY VisitDate) AS Daily_Trend
    FROM 
        april_data
	WHERE
		VisitDate<='2023-04-14' AND CourseID='S1B1'
	AND
		Status='Enrolled'
	GROUP BY
		VisitDate
),
Reg_trends AS (
	SELECT 
		VisitDate,
		Daily_reg,
        Daily_Trend,
		LAG(Daily_reg) OVER (ORDER BY VisitDate) AS PrevDayReg
	FROM
		Reg_count
	)
SELECT 
	DATE(VisitDate) AS Reg_Date,
	Daily_reg,
    Daily_Trend,
    CASE 
        WHEN PrevDayReg IS NULL THEN NULL 
        ELSE ((Daily_reg - PrevDayReg) * 100.0 / PrevDayReg)
    END AS Trend_diff 
FROM 
	Reg_Trends 
ORDER BY 
	VisitDate;
    
    
-- CONVERSION RATE(REGISTRATIONS/UNIQUE VISITORS) 
WITH reguniq AS(
SELECT
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS UniqueVisitors
FROM
	april_data
WHERE
	CourseID='S1B1'
    )
SELECT
	TotalRegistrations,
    UniqueVisitors,
    ((TotalRegistrations / UniqueVisitors)*100) AS RegistrationsPerVisitor
FROM
	reguniq;
    
