select * from course_price;

#Drop-Off Rate
-- S1B1
WITH Funnel1 AS (
    SELECT 
        CourseID,
        date(VisitDate) AS Date,
        COUNT(DISTINCT VisitorID) AS Total_Visitors,
        COUNT(DISTINCT CASE WHEN locate('Register Button',VisitedPages) >0 THEN VisitorID END) AS Reached_Register,
        COUNT(DISTINCT CASE WHEN locate('Payment Page',VisitedPages) >0 THEN VisitorID END) AS Reached_Payment_Page,
        COUNT(DISTINCT CASE WHEN locate('Payment Success',VisitedPages) >0 THEN VisitorID END) AS Enrolled
    FROM 
		april_data
	WHERE
		CourseID='S1B1' AND VisitDate<='2023-04-14'
    GROUP BY 
		VisitDate
)
SELECT 
    CourseID,
    Date,
    Total_Visitors,
    Reached_Register,
    Reached_Payment_Page,
    Enrolled,
	ROUND((Total_Visitors - Reached_Register) * 100.0 / NULLIF(Total_Visitors, 0), 2) AS Dropoff_at_Registration,
    ROUND((Reached_Register - Reached_Payment_Page) * 100.0 / NULLIF(Reached_Register, 0), 2) AS Dropoff_Before_Payment,
    ROUND((Reached_Payment_Page - Enrolled) * 100.0 / NULLIF(Reached_Payment_Page, 0), 2) AS Dropoff_At_Payment
FROM 
	Funnel1
ORDER BY 
	Date;
    
-- SB2,SB3,SB4,EB1,SQLB1 and DAIB1
WITH Funnel2 AS (
    SELECT 
        CourseID,
        VisitDate,
        COUNT(DISTINCT VisitorID) AS Total_Visitors,
        COUNT(DISTINCT CASE WHEN locate('Courses',VisitedPages) >0 THEN VisitorID END) AS Reached_Courses,
        COUNT(DISTINCT CASE WHEN locate('Course Details',VisitedPages) >0 THEN VisitorID END) AS Reached_Course_Details,
        COUNT(DISTINCT CASE WHEN locate('Register Button',VisitedPages) >0 THEN VisitorID END) AS Reached_Register,
        COUNT(DISTINCT CASE WHEN locate('Payment Page',VisitedPages) >0 THEN VisitorID END) AS Reached_Payment_Page,
        COUNT(DISTINCT CASE WHEN locate('Payment Success',VisitedPages) >0 THEN VisitorID END) AS Enrolled
    FROM 
		may_data
	WHERE
		VisitDate>='2023-05-01'
    GROUP BY 
		CourseID,
		VisitDate
        
	UNION ALL
    
    SELECT 
        CourseID,
        VisitDate,
        COUNT(DISTINCT VisitorID) AS Total_Visitors,
        COUNT(DISTINCT CASE WHEN locate('Courses',VisitedPages) >0 THEN VisitorID END) AS Reached_Courses,
        COUNT(DISTINCT CASE WHEN locate('Course Details',VisitedPages) >0 THEN VisitorID END) AS Reached_Course_Details,
        COUNT(DISTINCT CASE WHEN locate('Register Button',VisitedPages) >0 THEN VisitorID END) AS Reached_Register,
        COUNT(DISTINCT CASE WHEN locate('Payment Page',VisitedPages) >0 THEN VisitorID END) AS Reached_Payment_Page,
        COUNT(DISTINCT CASE WHEN locate('Payment Success',VisitedPages) >0 THEN VisitorID END) AS Enrolled
    FROM 
		june_data
    GROUP BY 
		CourseID,
		VisitDate
        
	UNION ALL
    
    SELECT 
        CourseID,
        VisitDate,
        COUNT(DISTINCT VisitorID) AS Total_Visitors,
        COUNT(DISTINCT CASE WHEN locate('Courses',VisitedPages) >0 THEN VisitorID END) AS Reached_Courses,
        COUNT(DISTINCT CASE WHEN locate('Course Details',VisitedPages) >0 THEN VisitorID END) AS Reached_Course_Details,
        COUNT(DISTINCT CASE WHEN locate('Register Button',VisitedPages) >0 THEN VisitorID END) AS Reached_Register,
        COUNT(DISTINCT CASE WHEN locate('Payment Page',VisitedPages) >0 THEN VisitorID END) AS Reached_Payment_Page,
        COUNT(DISTINCT CASE WHEN locate('Payment Success',VisitedPages) >0 THEN VisitorID END) AS Enrolled
    FROM 
		july_data_20230715
    GROUP BY 
		CourseID,
		VisitDate
)
SELECT 
    CourseID,
    date(VisitDate) AS Date,
    Total_Visitors,
    Reached_Courses,
    Reached_Course_Details,
    Reached_Register,
    Reached_Payment_Page,
    Enrolled,
	ROUND((Total_Visitors - Reached_Courses) * 100.0 / NULLIF(Total_Visitors, 0), 2) AS Dropoff_at_Courses,
    ROUND((Reached_Courses - Reached_Course_Details) * 100.0 / NULLIF(Reached_Courses, 0), 2) AS Dropoff_at_CourseDetails,
    ROUND((Reached_Course_Details - Reached_Register) * 100.0 / NULLIF(Reached_Course_Details, 0), 2) AS Dropoff_at_Registration,
    ROUND((Reached_Register - Reached_Payment_Page) * 100.0 / NULLIF(Reached_Register, 0), 2) AS Dropoff_Before_Payment,
    ROUND((Reached_Payment_Page - Enrolled) * 100.0 / NULLIF(Reached_Payment_Page, 0), 2) AS Dropoff_At_Payment
FROM 
	Funnel2
ORDER BY 
	CourseID,
	Date;
    

    
    
#CONVERSION RATES(CR),COST PER ACQUISITION(CPA),RETURN ON INVESTMENT(ROI)

WITH reguniq AS(
SELECT
	monthname(VisitDate) AS Month,
	CourseID,
    CampaignID,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS TotalVisitors
FROM
	june_data
GROUP BY
	Month,
    CampaignID,
	CourseID
    
UNION ALL

SELECT
	monthname(VisitDate) AS Month,
	CourseID,
    CampaignID,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS TotalVisitors
FROM
	july_data_20230715
GROUP BY
	Month,
    CampaignID,
	CourseID
    )
SELECT
	r.Month,
	r.CourseID,
    r.CampaignID,
    c.platform,
	r.TotalRegistrations,
    r.TotalVisitors,
    SUM(c.budget) AS Total_budget,
    (r.TotalRegistrations * cp.Price) AS Revenue,
    ROUND((r.TotalRegistrations * 100.0) / NULLIF(r.TotalVisitors, 0), 2) AS Registration_Percentage,
    ROUND(SUM(c.budget) / NULLIF(r.TotalRegistrations, 0), 2) AS CPA,
    ROUND((((r.TotalRegistrations * cp.Price) - SUM(c.budget)) * 100.0) / NULLIF(SUM(c.budget), 0), 2) AS ROI
FROM
	reguniq r
JOIN
	campaigns c
ON
	c.course=r.CourseID
AND 
	c.campaign_id = r.CampaignID
JOIN 
	course_price cp 
ON 
	cp.Course = r.CourseID
GROUP BY
	r.Month,
	r.CourseID,
    r.CampaignID,
    c.platform,
    r.TotalRegistrations,
    r.TotalVisitors
ORDER BY
	r.Month,
	r.CourseID;