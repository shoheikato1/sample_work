/****** Script for SelectTopNRows command from SSMS  ******/
SELECT* INTO #temp_fabd from RAL_MI.dbo.FACT_AD_BY_DAY WHERE ONLINE_DATE BETWEEN '2020-01-10' and '2020-01-30'

SELECT 
case when [gap]*1 > 0 then 'post' when [gap]*1 < 0 then 'pre' end as Period,
VEHICLE_COND,
FOREIGNID,
[DW registered],
[platform__],
AVG(Daily_Avg_price) as Avg_price_by_period
--AVG(Daily_promoted_price) as Avg_promoted_by_period
INTO #summary

FROM(SELECT
	CalendarDate,
	DATEDIFF(day, CalendarDate, '2020-01-22') as gap,
	b.ForeignID,
	b.VEHICLE_COND,
	c.[platform__],
	case when charindex('topspot',UPSELL_LIST)>0  then 1 else 0 end as [DW registered],
	AVG(a.[Price]) as Daily_Avg_price,
	AVG(a.[STRIKETHROUGHPRICE]) as Daily_promoted_price

FROM #temp_fabd a 
LEFT JOIN [RAL_MI].[dbo].[DIM_ADS] b ON a.AD_ID = b.AD_ID
LEFT JOIN #list2 c ON b.FOREIGNID = c.AD_ID
LEFT JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] d ON a.ONLINE_DATE = d.CalendarDate

WHERE CalendarDate BETWEEN '2020-01-14' and '2020-01-30'
AND NOT VEHICLE_COND = 'Damaged'


GROUP BY
	case when charindex('topspot',UPSELL_LIST)>0  then 1 else 0 end,
	CalendarDate,
	DATEDIFF(day, CalendarDate, '2002-01-22'),
	c.[platform__],
	b.ForeignID,
	vehicle_cond) a

WHERE gap <> 0

GROUP BY
case when [gap]*1 > 0 then 'post' when [gap]*1 < 0 then 'pre' end,
VEHICLE_COND,
[platform__],
FOREIGNID,
[DW registered]

ORDER BY 1,2

--SELECT
--	DISTINCT(dimension31) as AD_ID,
--	--DATEDIFF(day, [date], '2020-01-22'),
--	case when DATEDIFF(day, [date], '2020-01-22') >0 then 'post' when DATEDIFF(day, [date], '2020-01-22') <0 then 'pre' end as period,
--	dimension29,
--	[platform]

--INTO #list
--FROM [Marketing_Sandbox].[dbo].[list]

--WHERE DATEDIFF(day, [date], '2020-01-22') <> 0

--GROUP BY
--	dimension31,
--	--DATEDIFF(day, [date], '2020-01-22'),
--	case when DATEDIFF(day, [date], '2020-01-22') >0 then 'post' when DATEDIFF(day, [date], '2020-01-22') <0 then 'pre' end,
--	dimension29,
--	[platform]

----SELECT DISTINCT([DW registered]) FROM #summary
drop table #summary
drop table #list2
--drop table #temp_fabd

SELECT
	RIGHT(AD_ID, LEN(AD_ID) - 3) AS AD_ID,
	[period],
	[dimension29],
	[platform] as platform__

INTO #list2
FROM #list

select
	AD_ID* from #list
select * from #summary