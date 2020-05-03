USE RAL_MI

/*
######################################################################################################################
Create Temp Table
######################################################################################################################
*/

select
	[ONLINE_DATE]
      ,[AD_ID]
      ,[COMPANY_ID]
      ,[IS_ONLINE]
      ,[IS_PRIVATE]
      ,[AUTO_TRADER]
      ,[AUTO_HEBDO]
      ,[PRICE]
      ,[UPSELL_COUNT]
      ,[CUSTOM_PHOTO_COUNT]
      ,[UPSELL_PL]
      ,[UPSELL_MB]

into #TMP_FACT_AD_BY_DAY --drop table #fact
from [RAL_MI].[dbo].[FACT_AD_BY_DAY] with(READUNCOMMITTED)	where ONLINE_DATE between '2017-03-01' and '2018-05-31'

--select * INTO [Marketing_Sandbox].[dbo].[Shohei_Inventory2] FROM #TMP_FACT_AD_BY_DAY 
--select* from #TMP_FACT_AD_BY_DAY

/*
######################################################################################################################
Filter out New Cars not on New Car Program
######################################################################################################################
*/

Select distinct 
	CalendarDate, [FiscalYear], [CalendarMonth], companyID 
	into #enablenewcar
	--drop table #enablenewcar
    From  ral_mi.[dbo].[DIM_COMPANY_ADDITIONAL] a (nolock)
    join   [marketing_sandbox].[dbo].[FISCALCALENDAR]  b (nolock)
    on     calendarDate between '2017-03-01' and '2018-05-31'       
    and calendarDate>=cast([RecordLifeStart] as date) 
    and calendarDate<=isnull([RecordLifeEnd],'September 1,2099')  
    and enablenewcarlisting=1

CREATE clustered index ind_nc on #enablenewcar(CalendarDate, companyID)


/*
######################################################################################################################
New Car Inventories - insert into New Car Temp Table
######################################################################################################################
*/

--drop table #PV_new
--drop table #PV_used

--select * from #PV_new
--where 
----TRIM LIKE ('%wagon%') and 
--SEARCHMAKE = 'Volvo'

--select top 100 * from #PV_used

Select   
		 b.FiscalYear as Year_,
		 --b.FiscalQuarter as Quarter_,
		 b.FiscalMonth as Month_,
		 nc.CalendarDate as Date_,
		 SEARCHMAKE,
		 SEARCHMODEL,
		 --TRIM,
		 --VEHICLE_FUEL_TYPE as fuel,
		 'New' as VEHICLE_COND,
		 a.COMPANY_ID,
         'Franchise' as Franchise,
		 --case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end AS CONTENT_TYPE,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
			  when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
			  else 'Other' END Province,
		 map.Territory as territory,
		 c.PV_NPV,
		 a.ad_ID
into #PV_new
--drop table #PV_new

/* "no lock" and "READUNCOMITTED" means the same thing */

from #TMP_FACT_AD_BY_DAY (nolock) a
	INNER JOIN marketing_sandbox.dbo.fiscalcalendar (nolock) b ON a.ONLINE_DATE = b.CalendarDate
	INNER JOIN [RAL_MI].[dbo].[dim_ads] (nolock) c ON a. ad_id = c.ad_id
	INNER JOIN #enablenewcar nc on a.ONLINE_DATE = nc.CalendarDate and a.COMPANY_ID = nc.CompanyID
	LEFT JOIN current_onl_company (nolock) d ON a.company_id = d.companyid
	LEFT JOIN [DTL].[CURR_SF_ACCOUNTS] (nolock) sf ON d.SourceForeignID = sf.TDSR_PPG_ID
	LEFT JOIN Marketing_Sandbox.dbo.ref_FSA_HeatMapTerritories (nolock) map on left(d.locationpostalcode,3) = map.[Forward Sortation Area]

where                       
     PV_NPV='pv' 
	 --and vehicle_cond='New' 
	 and is_online=1 and IS_PRIVATE=0     
	 and cast(AUTO_TRADER as int)+cast( AUTO_HEBDO as int)>0
	 --and Franchise_Type = 'Franchise'
	 --and company_Id = '36208'
	 --and not a.ad_id IN ('28145257','28437544','28494832','28494833','28541252')
	 --and SEARCHMAKE IN ('Volkswagen')

group by 
		 b.FiscalYear,
		 --b.FiscalQuarter,
		 b.FiscalMonth,
		 nc.CalendarDate,
		 SEARCHMAKE,
		 SEARCHMODEL,
 		 --TRIM,
		 --VEHICLE_FUEL_TYPE,
		 --VEHICLE_COND,
		 a.COMPANY_ID,
		 case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end,
		 map.Territory,
		 --sf.Franchise_type,
		 PV_NPV,
		 a.ad_ID

/*
######################################################################################################################
Used Car Inventories - insert into Used Car Temp Table (can be used for NPV)
######################################################################################################################
*/

Select   
		 b.FiscalYear as Year_,
		 --b.FiscalQuarter as Quarter_,
		 b.FiscalMonth as Month_,
		 b.CalendarDate as Date_,
		 SEARCHMAKE,
		 SEARCHMODEL,
 		 --TRIM,
		 --VEHICLE_FUEL_TYPE as fuel,	
		 VEHICLE_COND,
		 a.COMPANY_ID,
         sf.Franchise_type as Franchise,
		 --case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end AS CONTENT_TYPE,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end Province,
		 map.Territory as territory,
		 PV_NPV,
		 a.ad_ID

into #PV_used
--drop table #PV_used

/* "no lock" and "READUNCOMITTED" means the same thing */

from #TMP_FACT_AD_BY_DAY (nolock) a
	INNER JOIN marketing_sandbox.dbo.fiscalcalendar (nolock) b ON a.ONLINE_DATE = b.CalendarDate
	INNER JOIN dbo.dim_ads (nolock) c ON a. ad_id = c.ad_id
	LEFT JOIN current_onl_company (nolock) d ON a.company_id = d.companyid
	LEFT JOIN [DTL].[CURR_SF_ACCOUNTS] (nolock) sf ON d.SourceForeignID = sf.TDSR_PPG_ID
	LEFT JOIN Marketing_Sandbox.dbo.ref_FSA_HeatMapTerritories (nolock) map on left(d.locationpostalcode,3) = map.[Forward Sortation Area]

where                       
     PV_NPV='pv' 
	 and vehicle_cond='Used' 
	 and is_online=1 
	 and IS_PRIVATE=0     
	 and cast(AUTO_TRADER as int)+cast( AUTO_HEBDO as int)>0
	 --and SEARCHMAKE IN ('Volkswagen')

group by 
		 b.FiscalYear,
		 --b.FiscalQuarter,
		 b.FiscalMonth,
		 b.CalendarDate,
		 SEARCHMAKE,
		 SEARCHMODEL,
 		 --TRIM,
		 --VEHICLE_FUEL_TYPE as fuel,	
		 VEHICLE_COND,
		 a.COMPANY_ID,
         sf.Franchise_type,
		 --case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end AS CONTENT_TYPE,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end,
		 map.Territory,
		 PV_NPV,
		 a.ad_ID

/*
######################################################################################################################
Combine result from New_table + Used_table
######################################################################################################################
*/


SELECT
	Year_,
	Month_,
	Date_,
	SEARCHMAKE,
	SEARCHMODEL,
	--TRIM,
	VEHICLE_COND,
	company_id,
	Franchise,
	PV_NPV,
	territory,
	ad_id

	INTO #TEMP_INVENTORY2

	FROM
		#PV_new

UNION

SELECT
	Year_,
	Month_,
	Date_,
	SEARCHMAKE,
	SEARCHMODEL,
	--TRIM,
	VEHICLE_COND,
	company_id,
	Franchise,
	PV_NPV,
	territory,
	ad_id

	FROM
		#PV_used

SELECT *
INTO [Marketing_Sandbox].[dbo].[Shohei_Inventory]
FROM #TEMP_INVENTORY2

--DROP TABLE [Marketing_Sandbox].[dbo].[Shohei_Inventory]