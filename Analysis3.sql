select * from may_data where CourseID='SB4' and status='Enrolled';

#VISITING TRAFFIC FOR SB4
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
	CourseID='SB4' AND VisitedPages LIKE '%''Home''%' 
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
	CourseID='SB4' AND VisitedPages LIKE '%''Courses''%' 
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
	CourseID='SB4' AND VisitedPages LIKE '%''Course Details''%' 
GROUP BY
	VisitDate
        
UNION ALL

SELECT 
	monthname(VisitDate) as Visit_Month,
    CourseID,
    date(VisitDate) AS Date,
	'Register Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	may_data 
WHERE
	CourseID='SB4' AND VisitedPages LIKE '%''Register Button''%' 
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
	CourseID='SB4' AND VisitedPages LIKE '%''Payment Page''%' 
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
	CourseID='SB4' AND VisitedPages LIKE '%''Payment Success''%' 
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
		VisitDate>='2023-05-22' AND CourseID='SB4'
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
	CourseID='SB4'
GROUP BY
	Month; 
