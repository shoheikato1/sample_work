USE RAL_MI

/*
Create Pre-Post Database
*/

DECLARE 										
	@Post_End Datetime,
	@Post_Start Datetime,
	@Pre_Start Datetime,
	@Pre_End Datetime,
	@Yoy_Start Datetime,
	@Yoy_End Datetime
										
SET @Post_End = GETDATE() - 2 -- lead table has 2 days of delay
SET @Post_Start = '20200123'
SET @Pre_End = '20200121'
SET @Pre_Start = @Pre_End - DATEDIFF(day, @Post_Start, @Post_End)
SET @Yoy_Start = (select DATEADD(WEEKDAY,-364,@Post_Start))
SET @Yoy_End = (select DATEADD(WEEKDAY,-364,@Post_End))

--SELECT @Post_Start,@Post_End,@Pre_End,@Pre_Start,@Yoy_Start,@Yoy_End
--SELECT DATEDIFF(day, @Post_Start, @Post_End)

SELECT
CAST(CalendarDate as Date) as Date,
[LEAD_CATEGORY],
CASE            
	WHEN LEAD_TYPE = 'Phone' THEN 'Phone'       
	WHEN LEAD_PLATFORM = 'WEB' THEN 'Desktop'       
	WHEN LEAD_PLATFORM = 'MOB' THEN 'mDOT'       
	WHEN LEAD_PLATFORM like '%IOS%' THEN 'IOS'       
	WHEN LEAD_PLATFORM like 'ANDROID' THEN 'Andriod'        
		ELSE 'Other' END As Lead_Platform,
count(distinct(case when company_ID is not null then [RAL_MI_LEAD_KEY] end)) as professional_lead,
count(distinct(case when company_ID is null then [RAL_MI_LEAD_KEY] end)) as private_lead,
Case when CAST(CalendarDate as Date) = '2020-01-22' then 'na'
when CAST(CalendarDate as Date) > '2020-01-22' then 'post'
else 'pre' end as Term

INTO #post

FROM [RAL_MI].[dbo].[FACT_LEAD] a
LEFT JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] b ON a.LEAD_DATE = b.calendardate

WHERE CalendarDate BETWEEN @Pre_Start and @Post_End
AND LEAD_CATEGORY LIKE '%Trader%' AND LEAD_CATEGORY LIKE '%Web' AND LEAD_PLATFORM IN ('WEB','MOB')
AND LEAD_TOPIC_NAME not like '%widget%'

GROUP BY
CalendarDate,
[LEAD_CATEGORY],
CASE            
	WHEN LEAD_TYPE = 'Phone' THEN 'Phone'       
	WHEN LEAD_PLATFORM = 'WEB' THEN 'Desktop'       
	WHEN LEAD_PLATFORM = 'MOB' THEN 'mDOT'       
	WHEN LEAD_PLATFORM like '%IOS%' THEN 'IOS'       
	WHEN LEAD_PLATFORM like 'ANDROID' THEN 'Andriod'        
		ELSE 'Other' END,

Case when CAST(CalendarDate as Date) = '2020-01-22' then 'na'
when CAST(CalendarDate as Date) > '2020-01-22' then 'post'
else 'pre' end

ORDER BY
CalendarDate ASC

--SELECT * FROM #post
------------------------------------------------------------------------------------------------------
/* Create YoY Database 
   - @Pre_Start and @Post_End are replaced by @Yoy_Start and @Yoy_End respectively
*/

SELECT
CAST(CalendarDate as Date) as Date,
[LEAD_CATEGORY],
CASE            
	WHEN LEAD_TYPE = 'Phone' THEN 'Phone'       
	WHEN LEAD_PLATFORM = 'WEB' THEN 'Desktop'       
	WHEN LEAD_PLATFORM = 'MOB' THEN 'mDOT'       
	WHEN LEAD_PLATFORM like '%IOS%' THEN 'IOS'       
	WHEN LEAD_PLATFORM like 'ANDROID' THEN 'Andriod'        
		ELSE 'Other' END As Lead_Platform,
count(distinct(case when company_ID is not null then [RAL_MI_LEAD_KEY] end)) as professional_lead,
count(distinct(case when company_ID is null then [RAL_MI_LEAD_KEY] end)) as private_lead,
'YoY' as Term

INTO #yoy

FROM [RAL_MI].[dbo].[FACT_LEAD] a
LEFT JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] b ON a.LEAD_DATE = b.calendardate

WHERE CalendarDate BETWEEN @Yoy_Start and @Yoy_End
AND LEAD_CATEGORY LIKE '%Trader%' AND LEAD_CATEGORY LIKE '%Web' AND LEAD_PLATFORM IN ('WEB','MOB')
AND LEAD_TOPIC_NAME not like '%widget%'

GROUP BY
CalendarDate,
[LEAD_CATEGORY],
CASE            
	WHEN LEAD_TYPE = 'Phone' THEN 'Phone'       
	WHEN LEAD_PLATFORM = 'WEB' THEN 'Desktop'       
	WHEN LEAD_PLATFORM = 'MOB' THEN 'mDOT'       
	WHEN LEAD_PLATFORM like '%IOS%' THEN 'IOS'       
	WHEN LEAD_PLATFORM like 'ANDROID' THEN 'Andriod'        
		ELSE 'Other' END

ORDER BY
CalendarDate ASC


/*
Combine Pre - Post and YoY databases
*/

SELECT
[Date],
[Lead_category],
Lead_Platform,
SUM(professional_lead) as Professional_lead,
Term

FROM(

SELECT * FROM #post
UNION ALL
SELECT * FROM #yoy

) a

GROUP BY
[Date],
[Lead_category],
Lead_Platform,
Term

--drop table #post
--drop table #yoy
