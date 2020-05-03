SELECT* INTO #temp_fabd from RAL_MI.dbo.FACT_AD_BY_DAY WHERE ONLINE_DATE BETWEEN '2020-01-01' and '2020-02-10'


SELECT
	Distinct(b.ForeignID) as ad_id,
	b.VEHICLE_COND
	--case when charindex('topspot',UPSELL_LIST)>0  then 1 else 0 end as [DW registered],
	--AVG(a.[Price]) as Daily_Avg_price,
	--AVG(a.[STRIKETHROUGHPRICE]) as Daily_promoted_price

FROM #temp_fabd a 
LEFT JOIN [RAL_MI].[dbo].[DIM_ADS] b ON a.AD_ID = b.AD_ID
LEFT JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] c ON a.ONLINE_DATE = c.CalendarDate

WHERE CalendarDate BETWEEN '2020-01-01' and '2020-02-10'
AND NOT VEHICLE_COND = 'Damaged'
AND charindex('topspot',UPSELL_LIST)>0


GROUP BY
	b.ForeignID,
	--case when charindex('topspot',UPSELL_LIST)>0  then 1 else 0 end,
	vehicle_cond