USE RAL_MI

/*
######################################################################################################################
Create Temp Table
######################################################################################################################
*/

select * into #TMP_FACT_AD_BY_DAY --drop table #fact
from [RAL_MI].[dbo].[FACT_AD_BY_DAY] with(READUNCOMMITTED)	where ONLINE_DATE between '2018-06-01' and '2018-06-30'

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
    on     calendarDate between '2018-06-01' and '2018-06-30'       
    and calendarDate>=cast([RecordLifeStart] as date) 
    and calendarDate<=isnull([RecordLifeEnd],'September 1,2099')  
    and enablenewcarlisting=1

CREATE clustered index ind_nc on #enablenewcar(CalendarDate, companyID)

--drop table #enablenewcar

/*
######################################################################################################################
New Car Inventories - insert into New Car Temp Table
######################################################################################################################
*/

Select   
		 nc.CalendarDate as Date_,
		 OEM,
		 SEARCHMAKE,
		 SEARCHMODEL,
		 VEHICLE_COND,
		 count(distinct a.COMPANY_ID) as Numdealers,
         sf.Franchise_type as Franchise,
		 case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end AS CONTENT_TYPE,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
			  when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
			  else 'Other' END Province,
		 c.PV_NPV,
		 count(distinct a.ad_ID) as NumAds
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
	 and vehicle_cond='New' 
	 and is_online=1 and IS_PRIVATE=0     
	 and cast(AUTO_TRADER as int)+cast( AUTO_HEBDO as int)>0
	 and Franchise_Type = 'Franchise'
	 and OEM IN ('Toyota')

group by 
		 nc.CalendarDate,
		 OEM,
		 SEARCHMAKE,
		 SEARCHMODEL,
		 VEHICLE_COND,
		 case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end,
		 sf.Franchise_type,
		 PV_NPV

SELECT
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH,
	Make,
	Model,
	OEM,
	Franchise,
	PV_NPV,
	CONTENT_TYPE,
	Vehicle_cond,
	Province,
	monthly_average_dealers,
	monthly_average_ads
	
	FROM(

SELECT
	Year(Date_) as Year,
	Month(Date_) as Month,
	OEM,
	SEARCHMAKE as Make,
	SEARCHMODEL as Model,
	Franchise,
	Vehicle_cond,
	CONTENT_TYPE,
	Province,
	PV_NPV,
	Avg(Numdealers) as monthly_average_dealers,
	Avg(NumAds) as monthly_average_ads

FROM (

	SELECT
			 Date_,
			 OEM,
			 SEARCHMAKE,
			 SEARCHMODEL,
			 VEHICLE_COND,
			 Numdealers,
			 Franchise,
			 PV_NPV,
			 Province,
			 CONTENT_TYPE,
			 NumAds
	FROM
		#PV_new

		) a

GROUP BY
	Year(Date_),
	Month(Date_),
	OEM,
	SEARCHMAKE,
	SEARCHMODEL,
	Franchise,
	Vehicle_cond,
	Province,
	CONTENT_TYPE,
	PV_NPV
	) b

GROUP BY
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END,
	Make,
	Model,
	OEM,
	Franchise,
	PV_NPV,
	CONTENT_TYPE,
	Vehicle_cond,
	Province,
	monthly_average_dealers,
	monthly_average_ads

/*
######################################################################################################################
Used Car Inventories - insert into Used Car Temp Table (can be used for NPV)
######################################################################################################################
*/

Select   
		 b.CalendarDate as Date_,
		 SEARCHMAKE,
		 SEARCHMODEL,	
		 VEHICLE_COND,
		 count(distinct a.COMPANY_ID) as Numdealers,
         sf.Franchise_type as Franchise,
		 case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end AS CONTENT_TYPE,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end Province,
		 PV_NPV,
		 count(distinct a.ad_ID) as NumAds

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
	 --and IS_PRIVATE=0     
	 and cast(AUTO_TRADER as int)+cast( AUTO_HEBDO as int)>0
	 --and SEARCHMAKE IN ('Toyota')

group by 
		 b.CalendarDate,
		 SEARCHMAKE,
		 SEARCHMODEL,
		 VEHICLE_COND,
		 case when a.IS_PRIVATE = 1 then 'Private' else 'Professional' end,
		 sf.Franchise_type,
		 case when c.PROVINCE IN ('BC','AB','SK','MB','ON','QC') THEN c.Province
		 when c.Province IN ('NL','NB','NL','NS','PE') THEN 'Maritimes'
		 else 'Other' end,
		 PV_NPV

/*
######################################################################################################################
Combine result from New_table + Used_table
######################################################################################################################
*/


SELECT
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END as YEAR_MONTH,
	Make,
	Model,
	Franchise,
	PV_NPV,
	CONTENT_TYPE,
	Vehicle_cond,
	Province,
	monthly_average_dealers,
	monthly_average_ads
	
	FROM(

SELECT
	Year(Date_) as Year,
	Month(Date_) as Month,
	SEARCHMAKE as Make,
	SEARCHMODEL as Model,
	Franchise,
	Vehicle_cond,
	CONTENT_TYPE,
	Province,
	PV_NPV,
	Avg(Numdealers) as monthly_average_dealers,
	Avg(NumAds) as monthly_average_ads

FROM (

	SELECT
			 Date_,
			 SEARCHMAKE,
			 SEARCHMODEL,
			 VEHICLE_COND,
			 Numdealers,
			 Franchise,
			 PV_NPV,
			 Province,
			 CONTENT_TYPE,
			 NumAds
	FROM
		#PV_new

		) a

GROUP BY
	Year(Date_),
	Month(Date_),
	SEARCHMAKE,
	SEARCHMODEL,
	Franchise,
	Vehicle_cond,
	Province,
	CONTENT_TYPE,
	PV_NPV
	) b

GROUP BY
	cast(YEAR as varchar) + Case when len(Month)=1 THEN '0' + CAST(MONTH as varchar) ELSE CAST(MONTH as varchar) END,
	Make,
	Model,
	Franchise,
	PV_NPV,
	CONTENT_TYPE,
	Vehicle_cond,
	Province,
	monthly_average_dealers,
	monthly_average_ads