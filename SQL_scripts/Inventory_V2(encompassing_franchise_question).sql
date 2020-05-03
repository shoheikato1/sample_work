-- difference between inventory file and franchise breakdown file can be ascribed to that one breaks down data by province while the latter doesn't.
-- Because latter is summation of by-province average while the former is just average across Canada

USE RAL_MI

DECLARE @start_date datetime
DECLARE @end_date datetime

SET @start_date='2018-01-01'
SET @end_date='2019-09-30'

SELECT
Year_month,
SUM(NPV_Inventory) as NPV_Inventory,
Inventory_Type,
Inventory_Detail,
Make,
Model,
dealer_or_private,
vehicle_cond

FROM
(

SELECT
	CASE WHEN LEN(MONTH(ONLINE_DATE)) = 1 THEN CONCAT(YEAR(ONLINE_DATE),'0',MONTH(ONLINE_DATE)) ELSE concat(year(ONLINE_DATE),month(ONLINE_DATE)) END as Year_month,
	[PROVINCE] AS Dealer_Province,
	TDSR_ID,
	--Dealer_Name, 
	AVG(Ads) AS NPV_Inventory, 
	[CATEGORY_LEVEL2] AS Inventory_Type,
	[CATEGORY_LEVEL3] As Inventory_Detail,
	[SEARCHMAKE] AS Make,
	[Searchmodel] as Model,
	[Dealer/Private] as dealer_or_private,
	VEHICLE_COND

--INTO #temp_inv2

FROM (
	SELECT	[PROVINCE],
			[ONLINE_DATE],
			fc.CalendarQuarter as QUARTER,
			[SourceForeignID] AS TDSR_ID,
			[Name] AS Dealer_Name,
			[CATEGORY_LEVEL2],
			[CATEGORY_LEVEL3],
			[VEHICLE_COND],
			Case when b.COMPANY_ID IS NULL THEN 'Private' ELSE 'Dealer' end as [Dealer/Private],
			[SEARCHMAKE],
			[searchmodel],
			COUNT(a.[AD_ID]) AS Ads

	FROM	[dbo].[FACT_AD_BY_DAY] a JOIN [dbo].[DIM_ADS] b ON a.ad_id=b.ad_id 
		LEFT JOIN [dbo].[CURRENT_ONL_COMPANY] c ON a.COMPANY_ID=c.CompanyID
		LEFT JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] fc on fc.CalendarDate = a.ONLINE_DATE

	WHERE	[ONLINE_DATE] between @start_date and @end_date
		AND [PV_NPV]='NPV'
		AND [IS_PRIVATE]=0 
		AND [IS_ONLINE]=1
		AND ([AUTO_TRADER]=1 and [AUTO_HEBDO]=1)
		AND ([CATEGORY_LEVEL2] = 'Motorcycle')
		--AND ([CATEGORY_LEVEL2] LIKE ('%Water%') OR [CATEGORY_LEVEL2] LIKE ('Snow%') OR [CATEGORY_LEVEL2] LIKE ('Snow%') OR [CATEGORY_LEVEL2] IN ('ATV','Motorcycle'))
		--AND VEHICLE_COND = 'New'
		--AND [SEARCHMAKE] in ('Harley-Davidson','Yamaha','Suzuki','Polaris','Can-Am','Kawasaki')
		--AND SEARCHMAKE in ('Sea-Doo','Ski-Doo','Can-Am','Polaris','Yamaha','Honda','Kawasaki','Suzuki')

	GROUP BY
		[ONLINE_DATE],
		fc.CalendarQuarter,
		[PROVINCE],
		[SourceForeignID],
		[Name],
		[CATEGORY_LEVEL2],
		[CATEGORY_LEVEL3],
		Case when b.COMPANY_ID IS NULL THEN 'Private' ELSE 'Dealer'end,
		[VEHICLE_COND],
		[SEARCHMAKE],
		[SEARCHMODEL]
	) a

GROUP BY
	CASE WHEN LEN(MONTH(ONLINE_DATE)) = 1 THEN CONCAT(YEAR(ONLINE_DATE),'0',MONTH(ONLINE_DATE)) ELSE concat(year(ONLINE_DATE),month(ONLINE_DATE)) END,
	[PROVINCE],
	TDSR_ID,
	--Dealer_Name, 
	[CATEGORY_LEVEL2],
	[CATEGORY_LEVEL3],
	[SEARCHMAKE],
	searchmodel,
	[Dealer/Private],
	VEHICLE_COND

) s

GROUP BY

Year_month,
Inventory_Type,
Inventory_Detail,
Make,
Model,
dealer_or_private,
vehicle_cond

--SELECT DISTINCT(Inventory_Type) from #temp_inv2