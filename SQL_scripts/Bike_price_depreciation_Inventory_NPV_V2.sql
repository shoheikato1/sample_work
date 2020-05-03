USE [RAL_MI]

-- INVENTORY WITH HARD LEADS

SELECT *  INTO #TMP_FACT_AD_BY_DAY
FROM [dbo].[FACT_AD_BY_DAY]

WHERE ONLINE_DATE BETWEEN '2016-01-01' and '2018-04-30'
	AND IS_PRIVATE = '0'	
	
-- INVENTORY
------------------------------------------------------------------------------------------------------------------------------

SELECT
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH,
	--AD_ID,
	PV_NPV,
	--Inventory_Type,
	INVENTORY_TYPE,
	Inventory_Year,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	ID_COUNT,
	AVERAGE_PRICE

FROM (
SELECT
		YEAR([ONLINE_DATE]) as YEAR,
		MONTH([ONLINE_DATE]) as MONTH,
		PV_NPV,
		--CATEGORY_LEVEL2 as Inventory_Type,
		INVENTORY_TYPE,
		SEARCHYEAR as Inventory_Year,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND,
		AVG(Price) as AVERAGE_PRICE,
		COUNT(AD_ID) as ID_COUNT

	FROM (

		SELECT
					[ONLINE_DATE],
					a.AD_ID,
					PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END AS INVENTORY_TYPE,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price

			FROM	#TMP_FACT_AD_BY_DAY a 
				JOIN [dbo].[DIM_ADS] b ON a.ad_id=b.ad_id 
				JOIN [dbo].[CURRENT_ONL_COMPANY] c ON a.COMPANY_ID=c.CompanyID
				LEFT JOIN [DTL].[CURR_SF_ACCOUNTS] (nolock) sf ON c.SourceForeignID = sf.TDSR_PPG_ID
				JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] fc on fc.CalendarDate = a.ONLINE_DATE

			WHERE								
				--[ONLINE_DATE] BETWEEN '2016-01-01' AND '2018-04-30'							
				[PV_NPV]='NPV'
				AND [SEARCHYEAR] IN( '2016','2017','2018')
				AND [SEARCHMAKE] IN ('Harley-Davidson')
				--AND [SEARCHMODEL] IN ('Camry','Corolla','Civic','Accord','Focus','Escape')						
				AND b.COMPANY_ID IS NOT NULL
				AND IS_ONLINE = 1
				AND (AUTO_TRADER =1 OR AUTO_HEBDO = 1)
				AND SOURCE_ID = 5
				AND b.CATEGORY_LEVEL2 = 'motorcycle'
				AND PRICE BETWEEN 5000 AND 60000
				--AND NOT sf.Franchise_Type = 'NULL'	

		GROUP BY
					[ONLINE_DATE],
					a.AD_ID,
					PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price
		) a

	GROUP BY
		YEAR([ONLINE_DATE]),
		MONTH([ONLINE_DATE]),
		AD_ID,
		PV_NPV,
		--CATEGORY_LEVEL2,
		INVENTORY_TYPE,
		SEARCHYEAR,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND

		) b
GROUP BY
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END,
	--AD_ID,
	PV_NPV,
	--Inventory_Type,
	INVENTORY_TYPE,
	Inventory_Year,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	ID_COUNT,
	AVERAGE_PRICE

/*
#################################################################
#################################################################
#################################################################
##################################################################################################################################################################################
This version shows individual price and ad_id
##################################################################################################################################################################################
*/

SELECT
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH,
	--PV_NPV,
	AD_ID,
	LocationAddress,
	--CATEGORY_LEVEL2 as Inventory_Type,
	INVENTORY_TYPE,
	SEARCHYEAR,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	Price

FROM (
SELECT
		YEAR([ONLINE_DATE]) as YEAR,
		MONTH([ONLINE_DATE]) as MONTH,
		AD_ID,
		LocationAddress,
		--PV_NPV,
		--CATEGORY_LEVEL2 as Inventory_Type,
		INVENTORY_TYPE,
		SEARCHYEAR,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND,
		Price

	FROM (

		SELECT
					[ONLINE_DATE],
					a.AD_ID,
					LocationAddress,
					--PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END AS INVENTORY_TYPE,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price

			FROM	#TMP_FACT_AD_BY_DAY a 
				JOIN [dbo].[DIM_ADS] b ON a.ad_id=b.ad_id 
				JOIN [dbo].[CURRENT_ONL_COMPANY] c ON a.COMPANY_ID=c.CompanyID
				LEFT JOIN [DTL].[CURR_SF_ACCOUNTS] (nolock) sf ON c.SourceForeignID = sf.TDSR_PPG_ID
				JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] fc on fc.CalendarDate = a.ONLINE_DATE

			WHERE								
				--[ONLINE_DATE] BETWEEN '2016-01-01' AND '2018-04-30'							
				[PV_NPV]='NPV'
				AND [SEARCHYEAR] IN( '2016','2017','2018')
				AND [SEARCHMAKE] IN ('Harley-Davidson')
				--AND [SEARCHMODEL] IN ('Camry','Corolla','Civic','Accord','Focus','Escape')						
				AND b.COMPANY_ID IS NOT NULL
				AND IS_ONLINE = 1
				AND (AUTO_TRADER =1 OR AUTO_HEBDO = 1)
				AND SOURCE_ID = 5
				AND b.CATEGORY_LEVEL2 = 'motorcycle'
				AND PRICE BETWEEN 5000 AND 60000
				--AND NOT sf.Franchise_Type = 'NULL'	

		GROUP BY
					[ONLINE_DATE],
					a.AD_ID,
					LocationAddress,
					--PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price
		) a

	GROUP BY
		YEAR([ONLINE_DATE]),
		MONTH([ONLINE_DATE]),
		LocationAddress,
		AD_ID,
		--PV_NPV,
		--CATEGORY_LEVEL2 as Inventory_Type,
		INVENTORY_TYPE,
		SEARCHYEAR,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND,
		Price

		) b
GROUP BY
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END,
	AD_ID,
	LocationAddress,
	--PV_NPV,
	--CATEGORY_LEVEL2 as Inventory_Type,
	INVENTORY_TYPE,
	SEARCHYEAR,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	Price

/*
#####################################################################################################################################################
This version tracks initial ad_date in addition to online date
*/

SELECT
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH,
	cast(YEAR_START as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH_START as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH_START,
	--PV_NPV,
	--CATEGORY_LEVEL2 as Inventory_Type,
	INVENTORY_TYPE,
	SEARCHYEAR,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	Price

FROM (
SELECT
		YEAR([ONLINE_DATE]) as YEAR,
		MONTH([ONLINE_DATE]) as MONTH,
		YEAR([START_DATE]) as YEAR_START,
		MONTH([START_DATE]) as MONTH_START,
		--PV_NPV,
		--CATEGORY_LEVEL2 as Inventory_Type,
		INVENTORY_TYPE,
		SEARCHYEAR,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND,
		Price

	FROM (

		SELECT
					[ONLINE_DATE],
					[START_DATE],
					a.AD_ID,
					PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END AS INVENTORY_TYPE,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price

			FROM	#TMP_FACT_AD_BY_DAY a 
				JOIN [dbo].[DIM_ADS] b ON a.ad_id=b.ad_id 
				JOIN [dbo].[CURRENT_ONL_COMPANY] c ON a.COMPANY_ID=c.CompanyID
				LEFT JOIN [DTL].[CURR_SF_ACCOUNTS] (nolock) sf ON c.SourceForeignID = sf.TDSR_PPG_ID
				JOIN [Marketing_Sandbox].[dbo].[FiscalCalendar] fc on fc.CalendarDate = a.ONLINE_DATE

			WHERE								
				--[ONLINE_DATE] BETWEEN '2016-01-01' AND '2018-04-30'							
				[PV_NPV]='NPV'
				AND [SEARCHYEAR] IN( '2016','2017','2018')
				AND [SEARCHMAKE] IN ('Harley-Davidson')
				--AND [SEARCHMODEL] IN ('Camry','Corolla','Civic','Accord','Focus','Escape')						
				AND b.COMPANY_ID IS NOT NULL
				AND IS_ONLINE = 1
				AND (AUTO_TRADER =1 OR AUTO_HEBDO = 1)
				AND SOURCE_ID = 5
				AND b.CATEGORY_LEVEL2 = 'motorcycle'
				AND PRICE BETWEEN 5000 AND 60000
				--AND NOT sf.Franchise_Type = 'NULL'	

		GROUP BY
					[ONLINE_DATE],
					[START_DATE],
					a.AD_ID,
					PV_NPV,
					--CATEGORY_LEVEL2,
					CASE WHEN CATEGORY_LEVEL3 IN ('dirt motocross','minibike moped','trike','scooter') THEN 'Scooter/Trike/Motorcross'
						 WHEN CATEGORY_LEVEL3 IN ('street','Street/Standard') THEN ('Street/Standard')
						 WHEN CATEGORY_LEVEL3 IN ('touring') THEN ('Touring')
						 WHEN CATEGORY_LEVEL3 IN ('sport','performance','super sport','sport/super sport') THEN ('Sport')
						 WHEN CATEGORY_LEVEL3 IN ('custom','cruiser') THEN ('Cruiser')
						 WHEN CATEGORY_LEVEL3 IN ('dual purpose','off road','enduros') THEN ('Trail/Enduro') END,
					SEARCHYEAR,
					SEARCHMAKE,
					SEARCHMODEL,
					--Franchise_Type,
					VEHICLE_COND,
					Price
		) a

	GROUP BY
		YEAR([ONLINE_DATE]),
		MONTH([ONLINE_DATE]),
		YEAR([START_DATE]),
		MONTH([START_DATE]),
		--PV_NPV,
		--CATEGORY_LEVEL2 as Inventory_Type,
		INVENTORY_TYPE,
		SEARCHYEAR,
		SEARCHMAKE,
		SEARCHMODEL,
		--Franchise_Type,
		VEHICLE_COND,
		Price

		) b
GROUP BY
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END,
	cast(YEAR_START as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH_START as varchar) ELSE CAST(MONTH as varchar) END,
	--PV_NPV,
	--CATEGORY_LEVEL2 as Inventory_Type,
	INVENTORY_TYPE,
	SEARCHYEAR,
	SEARCHMAKE,
	SEARCHMODEL,
	--Franchise_Type,
	VEHICLE_COND,
	Price