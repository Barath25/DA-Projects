SELECT count(*),variant,VisitDate FROM july_data_20230715 where Status='Enrolled' GROUP BY variant,VisitDate;
SELECT * FROM campaign_metrics_july; -- where VisitDate<='2023-07-15' and CampaignID!='Content';
SELECT * from july_data_20230715;
select * from campaigns;


DELETE
FROM
	july_data_20230715
WHERE
	CourseID IS NULL;
    
#VISITING TRAFFIC (PAGE WISE) FOR BOTH VARIANTS
WITH July AS(
SELECT
	Variant,
    date(VisitDate) AS Date,
	'Home' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Home''%'
GROUP BY
	Variant,
	Date
        
UNION ALL

SELECT
	Variant,
    date(VisitDate) AS Date,
	'Courses' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Courses''%'
GROUP BY
	Variant,
    Date
        
UNION ALL

SELECT
	Variant,
    date(VisitDate) AS Date,
	'Course Details' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Course Details''%'
GROUP BY
	Variant,
    Date
        
UNION ALL

SELECT 
	Variant,
    date(VisitDate) AS Date,
	'Register Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Register Button''%'
GROUP BY
	Variant,
    Date
        
UNION ALL

SELECT
	Variant,
    date(VisitDate) AS Date,
	'Payment Page' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Payment Page''%'
GROUP BY
	Variant,
    Date
        
UNION ALL

SELECT 
	Variant,
    date(VisitDate) AS Date,
	'Payment Success' AS Page,
    COUNT(DISTINCT VisitorID) AS Count,
    AVG(TimeSpent) AS Avg_Time
FROM
	july_data_20230715 
WHERE
	VisitedPages LIKE '%''Payment Success''%'
GROUP BY
	Variant,
    Date
)

SELECT
	Variant,
    Date,
    Page,
    Count,
    Avg_Time
FROM
	July
ORDER BY
	Variant;
	


#REGISTRATION DATA
-- TOTAL NUMBER OF REGISTRATION ALONG WITH DAILY REGISTRATION TRENDS
WITH Reg_count AS (
    SELECT 
        VisitDate,
        Variant,
        COUNT(*) AS Daily_reg,
        SUM(COUNT(*)) OVER (PARTITION BY Variant ORDER BY VisitDate) AS Daily_Trend
    FROM 
        july_data_20230715
	WHERE
		Status='Enrolled'
	GROUP BY
		Variant,
		VisitDate
),
Reg_trends AS (
	SELECT 
		VisitDate,
        Variant,
		Daily_reg,
        Daily_Trend,
		LAG(Daily_reg) OVER (PARTITION BY Variant ORDER BY VisitDate) AS PrevDayReg
	FROM
		Reg_count
	)
SELECT 
	DATE(VisitDate) AS Reg_Date,
    Variant,
	Daily_reg,
    Daily_Trend,
    CASE 
        WHEN PrevDayReg IS NULL THEN NULL 
        ELSE ((Daily_reg - PrevDayReg) * 100.0 / PrevDayReg)
    END AS Trend_diff 
FROM 
	Reg_Trends 
ORDER BY 
	Variant,
	VisitDate;
    
    
    
-- CONVERSION RATE(REGISTRATIONS/UNIQUE VISITORS) 
WITH reguniq AS(
SELECT
	Variant,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS UniqueVisitors
FROM
	july_data_20230715
GROUP BY
	Variant
    )
SELECT
	Variant,
	TotalRegistrations,
    UniqueVisitors,
    ((TotalRegistrations * 100.0) / UniqueVisitors) AS RegistrationsPerVisitor
FROM
	reguniq;
    
    
    
#DAIB 1
#CLICK THROUGH RATE(CLR),CONVERSION,COST PER CLICK(CPC) AND COST PER ACQUISITION(CPA)
#CLR
-- TOTAL USERS CLICKED THE AD AND TOTAL USERS WATCHED THE AD
-- TOTAL CLICKS / TOTAL IMPRESSIONS
#CONVERSION
-- TOTAL USERS COMPLETED THE REGISTRATION
-- TOTAL CONVERSIONS / TOTAL CLICKS
#CPC
-- TOTAL COST / TOTAL CLICKS
#CPA
-- TOTAL COST / TOTAL CONVERSIONS
SELECT
	cm.Variant,
	cm.CampaignID,
    c.course,
	SUM(cm.impressions) AS Total_impr,
    SUM(cm.clicks) AS Total_clicks,
    SUM(cm.conversions) AS Total_conv,
    (SUM(cm.clicks) * 100.0) / NULLIF(SUM(cm.impressions), 0) AS Click_thru_rate,
    (SUM(cm.conversions) * 100.0) / NULLIF(SUM(cm.clicks), 0) AS Conversions,
    SUM(c.budget) AS Total_budget,
    SUM(c.budget) / NULLIF(SUM(cm.clicks), 0) AS CPC,
    SUM(c.budget) / NULLIF(SUM(cm.conversions), 0) AS CPA
FROM
	campaign_metrics_july cm
JOIN
	campaigns c
ON
	cm.CampaignID=c.campaign_id
WHERE
	c.course='DAIB 1' AND Variant!='A or B'
GROUP BY
	cm.Variant,
    c.course,
	cm.CampaignID
ORDER BY
	cm.CampaignID,
    cm.Variant;
