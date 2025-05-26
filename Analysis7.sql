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
    
-- SB2,SB3 AND SB4
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
-- S1B1
WITH reguniq AS(
SELECT
	monthname(VisitDate) AS Month,
	CourseID,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS TotalVisitors
FROM
	april_data
WHERE
	CourseID='S1B1'
GROUP BY
	Month,
	CourseID
    )
SELECT
	r.Month,
	r.CourseID,
	r.TotalRegistrations,
    r.TotalVisitors,
    cp.Price,
    ROUND((TotalRegistrations * 100.0) / NULLIF(TotalVisitors, 0), 2) AS Registration_Percentage,
    ROUND((TotalRegistrations * cp.Price) / NULLIF(TotalRegistrations, 0), 2) AS CPA
FROM
	reguniq r
JOIN
	course_price cp
ON
	cp.Course=r.CourseID;
    
-- SB2,SB3 AND SB4
WITH reguniq AS(
SELECT
	monthname(VisitDate) AS Month,
	CourseID,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS TotalVisitors
FROM
	april_data
WHERE
	CourseID='SB2'
GROUP BY
	Month,
	CourseID
    
UNION ALL

SELECT
	monthname(VisitDate) AS Month,
	CourseID,
	COUNT(DISTINCT CASE WHEN Status = 'Enrolled' THEN VisitorID END) AS TotalRegistrations,
    COUNT(DISTINCT VisitorID) AS TotalVisitors
FROM
	may_data
GROUP BY
	Month,
	CourseID
    )
SELECT
	r.Month,
	r.CourseID,
	r.TotalRegistrations,
    r.TotalVisitors,
    cp.Price,
    ROUND((TotalRegistrations * 100.0) / NULLIF(TotalVisitors, 0), 2) AS Registration_Percentage,
    ROUND((TotalRegistrations * cp.Price) / NULLIF(TotalRegistrations, 0), 2) AS CPA
FROM
	reguniq r
JOIN
	course_price cp
ON
	cp.Course=r.CourseID
ORDER BY
	r.Month,
    r.CourseID;