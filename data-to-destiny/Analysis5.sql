SELECT * FROM course_price;
SELECT * FROM campaigns;

alter table april_data
add column CampaignId VARCHAR(20);

alter table may_data
add column CampaignId VARCHAR(20);

    
WITH Combined_Data AS (
    SELECT VisitorID, NULL AS CampaignID, CourseID, Status,monthname(VisitDate)AS Month,year(VisitDate) AS Year FROM april_data
    UNION ALL
    SELECT VisitorID, NULL AS CampaignID, CourseID, Status,monthname(VisitDate)AS Month,year(VisitDate) AS Year FROM may_data
    UNION ALL
    SELECT VisitorID, CampaignID, CourseID, Status,monthname(VisitDate)AS Month,year(VisitDate)AS Year FROM june_data
)

SELECT
	cd.Year,
    cd.Month,
    COALESCE(c.Platform, 'Organic') AS Platform,  -- Assign 'Organic' if CampaignID is NULL
    cp.Course,
    cp.Price,
    
    -- Monthly Visitor Count per Platform
    COUNT(CASE WHEN cd.Month = 'April' THEN cd.VisitorId END) AS Apr_visitor,
    COUNT(CASE WHEN cd.Month = 'May' THEN cd.VisitorId END) AS May_visitor,
    COUNT(CASE WHEN cd.Month = 'June' THEN cd.VisitorId END) AS June_visitor,
    
    -- Monthly Total Sales per Platform
    COUNT(CASE WHEN cd.Month = 'April' THEN cd.VisitorId END) * cp.Price AS Apr_Total_Sales,
    COUNT(CASE WHEN cd.Month = 'May' THEN cd.VisitorId END) * cp.Price AS May_Total_Sales,
    COUNT(CASE WHEN cd.Month = 'June' THEN cd.VisitorId END) * cp.Price AS June_Total_Sales,

    -- Total Sales Across All Months
    COUNT(*) AS Total_sales,
    
    -- Total Revenue Across All Months
	SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cd.Year) AS Total_Expenditure,
    
    -- Total Revenue by Months
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cd.Month) AS Exp_Month,
     
    -- Total Revenue by Months and Platform
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cd.Month,c.Platform) AS Exp_Month_Plat,

	-- Total Revenue by Months,Platform and Course
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cd.Month,c.Platform,cp.Course) AS Exp_Month_Plat_Course,
     
    -- Total Revenue by Platform 
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY c.Platform) AS Exp_Plat,
     
    -- Total Revenue by Platform and Course
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY c.Platform,cp.Course) AS Exp_Plat_Course,
     
    -- Total Revenue by Course
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cp.Course) AS Exp_Course,
     
    -- Total Revenue by Course and Months
    SUM(cp.Price * COUNT(*)) OVER (PARTITION BY cd.Month,cp.Course) AS Exp_Month_Course

FROM 
	Combined_Data cd
LEFT JOIN 
	campaigns c ON cd.CampaignID = c.Campaign_Id  
JOIN 
	course_price cp ON cp.Course = cd.CourseID
WHERE 
	cd.CourseID NOT IN ('DAIB 1')
AND 
	cd.Status = 'Enrolled'
GROUP BY 
	cd.Year,cd.Month, c.Platform, cp.Course, cp.Price
ORDER BY cd.Month, c.Platform, cp.Course;