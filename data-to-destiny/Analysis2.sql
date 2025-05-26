#MAY_DATA FOR SB2
SELECT
	*
FROM
	may_data where CourseID='SB2';
    
#DATA CLEANING - removing rows that is not associated with any of the courseid
DELETE 
FROM 
	may_data 
WHERE 
	CourseID is NULL;
UPDATE april_data
SET VisitedPages='[''Home'', ''Courses'', ''Course Details'', ''Register Button'', ''Payment Page'', ''Payment Success'']'
WHERE CourseID='SB2';

#VISITING TRAFFIC (PAGE WISE) FOR SB2 STARTING FROM MAY01,2023
WITH Combined_Data AS(
-- MAY DATA FOR SB2
SELECT
	VisitDate,
    CourseID,
    'Home' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Home''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	VisitDate,
    CourseID,
    'Courses' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Courses''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	VisitDate,
    CourseID,
    'Course Details' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Course Details''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT 
	VisitDate,
    CourseID,
    'Register Button' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Register Button''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	VisitDate,
    CourseID,
    'Payment Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Payment Page''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT 
	 VisitDate,
     CourseID,
     'Payment Success' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB2' AND VisitedPages LIKE '%''Payment Success''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
)	
SELECT
	monthname(VisitDate) AS Month,
    CourseID,
    date(VisitDate) AS Date,
    Page,
    SUM(Count) AS Total_Visitors,
    Round(Avg(Avg_Time),2) AS Avg_Time_Spent
FROM
	Combined_Data
GROUP BY
	Month,Date,CourseID,Page
ORDER BY
	Month,Date;

#REGISTRATION DATA
-- TOTAL NUMBER OF REGISTRATION ALONG WITH DAILY REGISTRATION TRENDS
WITH Reg_count AS (
    SELECT 
        VisitDate,
        COUNT(*) AS Daily_reg,
        SUM(COUNT(*)) OVER (PARTITION BY MONTH(VisitDate) ORDER BY VisitDate) AS Daily_Trend
    FROM 
        may_data
	WHERE
		VisitDate>='2023-05-01' AND CourseID='SB2'
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
 
#CONVERSION RATE(REGISTRATIONS/UNIQUE VISITORS) 
SELECT
	monthname(VisitDate) AS Month,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS UniqueVisitors,
    (COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) * 100 / NULLIF(COUNT(DISTINCT VisitorID),0)) AS RegPercentage
FROM
	may_data 
WHERE
	CourseID='SB2'
GROUP BY
	Month; 
    
   
   
   
#MAY_DATA FOR SB3
SELECT
	*
FROM
	may_data where CourseID='SB3' and Status='Enrolled';
    
#VISITING TRAFFIC FOR SB3 STARTING FROM MAY01,2023
WITH May_Data AS(
SELECT
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Home' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Home''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Courses' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Courses''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Course Details' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Course Details''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT 
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Register Button' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Register Button''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Payment Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Payment Page''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
        
UNION ALL

SELECT 
	 monthname(VisitDate) as Visit_Month,
     CourseID,
     date(VisitDate) AS Date,
	'Payment Success' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB3' AND VisitedPages LIKE '%''Payment Success''%' AND date(VisitDate)>='2023-05-01'
GROUP BY
	VisitDate
)
SELECT
	Visit_Month,
    CourseID,
    Date,
    Page,
    Count,
    Avg_Time
FROM
	May_Data
ORDER BY
	Date;

#REGISTRATION DATA
-- TOTAL NUMBER OF REGISTRATION ALONG WITH DAILY REGISTRATION TRENDS
WITH Reg_count AS (
    SELECT 
        VisitDate,
        COUNT(*) AS Daily_reg,
        SUM(COUNT(*)) OVER (PARTITION BY MONTH(VisitDate) ORDER BY VisitDate) AS Daily_Trend
    FROM 
        may_data
	WHERE
		VisitDate>='2023-05-01' AND CourseID='SB3'
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

#CONVERSION RATE(REGISTRATIONS/UNIQUE VISITORS) 
WITH reguniq AS(
SELECT
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS UniqueVisitors
FROM
	may_data
WHERE
	CourseID='SB3'
    )
SELECT
	TotalRegistrations,
    UniqueVisitors,
    (TotalRegistrations * 100 / UniqueVisitors) AS RegistrationsPercentage
FROM
	reguniq;    