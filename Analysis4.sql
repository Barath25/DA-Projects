select * from campaign_metrics_june;
select * from campaigns;
select * from june_data;
select * from june_data where Status='Enrolled' and CourseID='EB1'; -- 305
select * from june_data where Status='Enrolled' and CourseID='EB1' and CampaignID=''; -- 179
select * from june_data where Status='Enrolled' and CourseID='EB1' and CampaignID!=''; -- 126


select * from june_data where Status='Enrolled' and CourseID='SQLB1'; -- 536
select * from june_data where Status='Enrolled' and CourseID='SQLB1' and CampaignID=''; -- 179
select * from june_data where Status='Enrolled' and CourseID='SQLB1' and CampaignID!=''; -- 357
select * from june_data where Status='Enrolled' and CourseID='SQLB1' and CampaignID='IG3' AND VisitDate>='2023-06-03'; -- 83
select * from june_data where Status='Enrolled' and CourseID='SQLB1' and CampaignID='YT2' AND VisitDate>='2023-06-02'; -- 247

#Data Cleaning
DELETE
FROM
	june_data
WHERE
	CourseID IS NULL AND CampaignID='';
    
DELETE
FROM
	june_data
WHERE
	CourseID IS NULL;

#EXCEL
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
	cm.campaign_id,
    c.platform,
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
	campaign_metrics_june cm
LEFT JOIN
	campaigns c
ON
	cm.campaign_id=c.campaign_id
JOIN
	june_data june
ON
	c.course=june.CourseID
WHERE
	c.course='EB1' AND june.Status='Enrolled' AND june.CampaignID!=''
GROUP BY
	cm.campaign_id,
    c.platform;
    
    
    
    
#SQL    
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
	cm.campaign_id,
    c.platform,
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
	campaign_metrics_june cm
LEFT JOIN
	campaigns c
ON
	cm.campaign_id=c.campaign_id
JOIN
	june_data june
ON
	c.course=june.CourseID
WHERE
	c.course='SQLB1' AND june.Status='Enrolled' AND june.CampaignID!='' AND (
        (c.platform = 'Instagram' AND DATE(june.VisitDate) >= '2023-06-03') OR
        (c.platform = 'YouTube' AND DATE(june.VisitDate) >= '2023-06-02')
    )
GROUP BY
	cm.campaign_id,
    c.platform,
    c.course;   