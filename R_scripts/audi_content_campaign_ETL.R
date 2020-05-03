# Step 0: Install necessary packages

#install.packages("RGA")
#install.packages("sqldf")
#install.packages("googlesheets")
#install.packages("dplyr")
#install.packages("xlsx")


#1: activate RGA library#
suppressMessages(library(RGA))
suppressMessages(library(sqldf))
suppressMessages(library(dplyr))
suppressMessages(library(googlesheets))
suppressMessages(library(rdfp))
suppressMessages(library(xlsx))
suppressMessages(library(sys))

#2: Create Report

### DFP ####
# options(rdfp.network_code = 8544)
# dfp_auth()
# 
# #filterstatement <- list()
# 
# #start date
# startd_dfp <- list(year=2019, month=1, day=1)
# 
# #end date
# end_year <- as.numeric(format(Sys.Date()-1, "%Y"))
# end_month <- as.numeric(format(Sys.Date()-1, "%m"))
# end_day <- as.numeric(format(Sys.Date()-1, "%d")) #careful NO %D because that'll give you full range date!
# 
# endd_dfp <- list(year=end_year,month=end_month,day=end_day)
# rm("end_year","end_month","end_day")
# 
# #filterStatement =list('query'="WHERE ORDER_NAME =@ 'QX50 | INFINITI'")
# #dfp_getCompaniesByStatement_result <- dfp_getCompaniesByStatement(request_data)
# 
# 
# request_data <- list(reportJob =
#                        list(reportQuery =
#                               list(dimensions = 'WEEK',
#                                    dimensions = 'ORDER_NAME',
#                                    dimensions = 'CREATIVE_NAME',
#                                    dimensions = 'LINE_ITEM_NAME',
#                                    adUnitView = 'FLAT',
#                                    columns = 'TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS', 
#                                    columns = 'TOTAL_LINE_ITEM_LEVEL_CLICKS',
#                                    startDate= startd_dfp,
#                                    endDate=  endd_dfp,
#                                    dateRangeType = 'CUSTOM_DATE')
#                        )
# )
# request_data <- dfp_full_report_wrapper(request_data)
# 
# colnames(request_data) <- c("Week","order_name","creative_name","line_name","order_id","creative_id","line_id","impressions","clicks")
# 
# #dfp_auth(token = NULL, new_user = FALSE,
# #         addtl_scopes = c("https://spreadsheets.google.com/feeds",
# #                          "https://www.googleapis.com/auth/drive",
# #                          "https://www.googleapis.com/auth/spreadsheets",
# #                          "https://www.googleapis.com/auth/presentations",
# #                          "https://www.googleapis.com/auth/analytics",
# #                          "https://www.googleapis.com/auth/yt-analytics.readonly",
# #                          "https://www.googleapis.com/auth/gmail.readonly",
# #                          "https://www.googleapis.com/auth/gmail.compose",
# #                          "https://www.googleapis.com/auth/gmail.send"),
# #         key = getOption("rdfp.client_id"),
# #         secret = getOption("rdfp.client_secret"),
# #         cache = getOption("rdfp.httr_oauth_cache"), verbose = TRUE)
# 
# #3 Retrieve first report\\
# 
# acura_cpo_dfp <- sqldf("
# 
#   SELECT
#   week,
#   sum(impressions) as impressions,
#   sum(clicks) as clicks,
#   'dfp' as platform
# 
#   FROM request_data
# 
#   WHERE order_name LIKE '%Acura_PHZ CPO%'
#   GROUP BY date
#           ")
# 
# acura_cpo_dfp <-subset(acura_cpo_dfp, date>= "2019-09-26")

########################### GA ####################################

# --- set up
ga_token <- authorize(client.id = '31019866036-gna21un48frn4qq6j288e159gdb1om88.apps.googleusercontent.com',
                      client.secret = 'nQ-logyzXwVArBKfrYX43zJZ')


#all_dim <- list_dimsmets()
#cust_dim <- list_custom_dimensions('10401800','UA-10401800-37')
#cust_met <- list_custom_metrics('10401800','UA-10401800-37')
#segments_master <- list_segments(start.index = NULL, max.results = NULL, ga_token)
#segments <- segments_master[grepl('Scroll', segments$name),]
duration <- 'day'

startD = '2020-02-19'


#  ACURA Article URLs
#  Index page
#   https://www.autotrader.ca/brandcampaign/audi/certifiedplus/en/index.html
# Article Pages
#   https://www.autotrader.ca/brandcampaign/audi/certifiedplus/en/foreveryoung.html
#   https://www.autotrader.ca/brandcampaign/audi/certifiedplus/en/justanumber.html
#   https://www.autotrader.ca/brandcampaign/audi/certifiedplus/en/mygamechanger.html
#   https://www.autotrader.ca/brandcampaign/audi/certifiedplus/en/abriefhistory.html

# REPORT: Number of Sessions

audi_CPO_session_desktop <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
                                       ,dimensions='ga:date,ga:hostname'
                                       ,metrics='ga:sessions'
                                       ,sort="ga:sessions"
                                       #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                                       ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020'
                                       ,token = ga_token
                                       ,fetch.by= duration)

audi_CPO_session_mdot <- get_ga(profileId = 'ga:112044696', start.date = startD, end.date = 'yesterday'
                                 ,dimensions='ga:date,ga:hostname'
                                 ,metrics='ga:sessions'
                                 ,sort="ga:sessions"
                                 #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                                 ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020'
                                 ,token = ga_token
                                 ,fetch.by= duration)

audi_CPO_session_desktop$platform <- "Desktop"
audi_CPO_session_mdot$platform <- "mDOT"

audi_CPO_session <- rbind(audi_CPO_session_desktop,audi_CPO_session_mdot)

audi_CPO_session <- sqldf("
SELECT
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end as host,
platform,
sessions

FROM audi_CPO_session

")

# REPORT: Pageview and Avg.Time on Page

audi_CPO_pageview_and_time_desktop <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
                            ,dimensions='ga:date,ga:pagePath,ga:hostname'
                            ,metrics='ga:pageviews,ga:avgTimeOnPage,ga:timeOnPage'
                            ,sort="ga:pageviews"
                            #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                            ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020'
                            ,token = ga_token
                            ,fetch.by= duration)

audi_CPO_pageview_and_time_mdot <- get_ga(profileId = 'ga:112044696', start.date = startD, end.date = 'yesterday'
                                              ,dimensions='ga:date,ga:pagePath,ga:hostname'
                                              ,metrics='ga:pageviews,ga:avgTimeOnPage,ga:timeOnPage'
                                              ,sort="ga:pageviews"
                                              #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                                              ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020'
                                              ,token = ga_token
                                              ,fetch.by= duration)

audi_CPO_pageview_and_time_desktop$platform <- "Desktop"
audi_CPO_pageview_and_time_mdot$platform <- "mDOT"

audi_CPO_pageview_and_time <- rbind(audi_CPO_pageview_and_time_desktop,audi_CPO_pageview_and_time_mdot)

audi_CPO_pageview_and_time <- sqldf("
SELECT
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end as host,
CASE WHEN pagePath LIKE '%/foreveryoung%' THEN 'stay young forever'
WHEN pagePath LIKE '%/justanumber%' then 'just a number'
WHEN pagePath LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
WHEN pagePath LIKE '%/mygamechanger%' THEN 'my game changer'
WHEN pagePath LIKE '%abriefhistory%' THEN 'a brief history'
ELSE 'index' END 'Page',
platform,
pageviews,
avgTimeOnPage,
timeOnPage


FROM audi_CPO_pageview_and_time

")

rm(audi_CPO_pageview_and_time_desktop,audi_CPO_pageview_and_time_mdot,audi_CPO_session_desktop,audi_CPO_session_mdot)

# REPORT: Session with scroll depth (cancalled)

# audi_CPO_scroll_0 <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
#                               ,dimensions='ga:date,ga:pagePath'
#                               ,metrics='ga:pageviews'
#                               ,sort="ga:sessions"
#                               #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
#                               ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020'
#                               ,token = ga_token
#                               ,fetch.by= duration)
# 
# audi_CPO_scroll_33 <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
#                          ,dimensions='ga:date,ga:pagePath'
#                          ,metrics='ga:sessions'
#                          ,sort="ga:sessions"
#                          ,segment = 'gaid::hoidYB6BS2yrBsHvwp6yEw'
#                          ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020/'
#                          ,token = ga_token
#                          ,fetch.by= duration)
# 
# audi_CPO_scroll_50 <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
#                               ,dimensions='ga:date,ga:pagePath'
#                               ,metrics='ga:sessions'
#                               ,sort="ga:sessions"
#                               ,segment = 'gaid::szznNuodRlSkIlv76h9BrA'
#                              ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020/'
#                              ,token = ga_token
#                               ,fetch.by= duration)
# 
# audi_CPO_scroll_75 <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
#                               ,dimensions='ga:date,ga:pagePath'
#                               ,metrics='ga:sessions'
#                               ,sort="ga:sessions"
#                               ,segment = 'gaid::_mauLNBMQVmar5tI_3RWjw'
#                              ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020/'
#                              ,token = ga_token
#                               ,fetch.by= duration)
# 
# audi_CPO_scroll_100 <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
#                               ,dimensions='ga:date,ga:pagePath'
#                               ,metrics='ga:sessions'
#                               ,sort="ga:sessions"
#                               ,segment = 'gaid::KR9C8bTqR_eO4xLygUJCAA'
#                               ,filter='ga:pagePath=@/brand-experience/audi-cpo/2020/'
#                               ,token = ga_token
#                               ,fetch.by= duration)
# 
# audi_CPO_scroll_0$Scroll <- 'Scroll 0%'
# audi_CPO_scroll_33$Scroll <- 'Scroll 33%'
# audi_CPO_scroll_50$Scroll <- 'Scroll 50%'
# audi_CPO_scroll_75$Scroll <- 'Scroll 75%'
# audi_CPO_scroll_100$Scroll <- 'Scroll 100%'
# 
# audi_CPO_scroll <- rbind(audi_CPO_scroll_0,audi_CPO_scroll_33,audi_CPO_scroll_50,audi_CPO_scroll_75,audi_CPO_scroll_100)
# rm(audi_CPO_scroll_0,audi_CPO_scroll_33,audi_CPO_scroll_50,audi_CPO_scroll_75,audi_CPO_scroll_100)
# 
# audi_CPO_scroll <- sqldf("
# SELECT
# date,
# case when hostname LIKE ('%rader%') then 'aT'
# when hostname LIKE ('%ebdo%') then 'aH'
# else 'other' end as host,
# CASE WHEN pagePath LIKE '%/foreveryoung%' THEN 'stay young forever'
# WHEN pagePath LIKE '%/justanumber%' then 'just a number'
# WHEN pagePath LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
# WHEN pagePath LIKE '%/mygamechanger%' THEN 'my game changer'
# WHEN pagePath LIKE '%abriefhistory%' THEN 'a brief history'
# ELSE 'index' END 'Page',
# Scroll,
# sessions
# 
# FROM audi_CPO_scroll
# 
# 
# ")

# REPORT: SCROLL EVENT COUNTS
audi_CPO_scroll_desktop <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
                              ,dimensions='ga:date,ga:hostname,ga:dimension79,ga:eventLabel'
                              ,metrics='ga:totalEvents'
                              ,sort="ga:totalEvents"
                              #,segment = 'gaid::KR9C8bTqR_eO4xLygUJCAA'
                              ,filter='ga:dimension79=@brandcampaign/audi/certifiedplus;ga:eventAction==scroll'
                              ,token = ga_token
                              ,fetch.by= duration)

audi_CPO_scroll_mdot <- get_ga(profileId = 'ga:112044696', start.date = startD, end.date = 'yesterday'
                           ,dimensions='ga:date,ga:hostname,ga:dimension79,ga:eventLabel'
                           ,metrics='ga:totalEvents'
                           ,sort="ga:totalEvents"
                           #,segment = 'gaid::KR9C8bTqR_eO4xLygUJCAA'
                           ,filter='ga:dimension79=@brandcampaign/audi/certifiedplus;ga:eventAction==scroll'
                           ,token = ga_token
                           ,fetch.by= duration)

audi_CPO_scroll_desktop$platform <- "Desktop"
audi_CPO_scroll_mdot$platform <- "mDOT"

audi_CPO_scroll <- rbind(audi_CPO_scroll_desktop,audi_CPO_scroll_mdot)

audi_CPO_scroll <- sqldf("
SELECT
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end as host,
CASE WHEN dimension79 LIKE '%/foreveryoung%' THEN 'stay young forever'
WHEN dimension79 LIKE '%/justanumber%' then 'just a number'
WHEN dimension79 LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
WHEN dimension79 LIKE '%/mygamechanger%' THEN 'my game changer'
WHEN dimension79 LIKE '%abriefhistory%' THEN 'a brief history'
ELSE 'index' END 'Page',
platform,
eventLabel,
sum(totalEvents) as totalEvents


FROM audi_CPO_scroll

GROUP BY
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end,
CASE WHEN dimension79 LIKE '%/foreveryoung%' THEN 'stay young forever'
WHEN dimension79 LIKE '%/justanumber%' then 'just a number'
WHEN dimension79 LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
WHEN dimension79 LIKE '%/mygamechanger%' THEN 'my game changer'
WHEN dimension79 LIKE '%abriefhistory%' THEN 'a brief history'
ELSE 'index' END,
platform,
eventLabel

")

rm(audi_CPO_scroll_desktop,audi_CPO_scroll_mdot)

# REPORT: EXIT CLICKS 

audi_CPO_exitclicks_outbound_desktop <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = 'yesterday'
                           ,dimensions='ga:date,ga:hostname,ga:dimension79,ga:eventAction'
                           ,metrics='ga:totalEvents'
                           ,sort="ga:totalEvents"
                           #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                           ,filter='ga:eventCategory==outbound;ga:dimension79=@brandcampaign/audi/certifiedplus'
                           ,token = ga_token
                           ,fetch.by= duration)

audi_CPO_exitclicks_outbound_mdot <- get_ga(profileId = 'ga:112044696', start.date = startD, end.date = 'yesterday'
                                ,dimensions='ga:date,ga:hostname,ga:dimension79,ga:eventAction'
                                ,metrics='ga:totalEvents'
                                ,sort="ga:totalEvents"
                                #,segment = 'gaid::jOulISN6Qj-XcaTreSTMQQ'
                                ,filter='ga:eventCategory==outbound;ga:dimension79=@brandcampaign/audi/certifiedplus'
                                ,token = ga_token
                                ,fetch.by= duration)

audi_CPO_exitclicks_outbound_desktop$platform <- "Desktop"
audi_CPO_exitclicks_outbound_mdot$platform <- "mDOT"

audi_CPO_exitclicks_outbound <- rbind(audi_CPO_exitclicks_outbound_desktop,audi_CPO_exitclicks_outbound_mdot)
                                
                                
audi_CPO_exitclicks_outbound <- sqldf("
SELECT
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end as host,
CASE WHEN dimension79 LIKE '%/foreveryoung%' THEN 'stay young forever'
WHEN dimension79 LIKE '%/justanumber%' then 'just a number'
WHEN dimension79 LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
WHEN dimension79 LIKE '%/mygamechanger%' THEN 'my game changer'
WHEN dimension79 LIKE '%abriefhistory%' THEN 'a brief history'
ELSE 'index' END 'Page',
platform,
sum(totalEvents) as TotalClicks

FROM audi_CPO_exitclicks_outbound

GROUP BY
date,
case when hostname LIKE ('%rader%') then 'aT'
when hostname LIKE ('%ebdo%') then 'aH'
else 'other' end,
CASE WHEN dimension79 LIKE '%/foreveryoung%' THEN 'stay young forever'
WHEN dimension79 LIKE '%/justanumber%' then 'just a number'
WHEN dimension79 LIKE '%acura-cpo-vs-used%' THEN 'cpo_vs_used'
WHEN dimension79 LIKE '%/mygamechanger%' THEN 'my game changer'
WHEN dimension79 LIKE '%abriefhistory%' THEN 'a brief history'
ELSE 'index' END,
platform

")

rm(audi_CPO_exitclicks_outbound_desktop,audi_CPO_exitclicks_outbound_mdot)


################### Weighted Session Duration ##############

weighted_average_dwell_time <- colSums(audi_CPO_pageview_and_time['timeOnPage'])/colSums(audi_CPO_session['sessions'])

################## EXPORT TO EXCEL #########################

file_name <- paste("audi_cpo_summary_",format(Sys.Date(), "%Y%m%d"),"_.xlsx")

  write.xlsx(audi_CPO_session, file = file_name, 
             sheetName="visit", append=FALSE,row.names = FALSE)
  write.xlsx(audi_CPO_scroll, file = file_name,
             sheetName="scroll", append=TRUE,row.names = FALSE)
  write.xlsx(audi_CPO_pageview_and_time, file = file_name, 
             sheetName="pageview_and_time", append=TRUE,row.names = FALSE)
  #write.xlsx(audi_CPO_article_click, file = file_name, 
  #           sheetName="article_click", append=TRUE,row.names = FALSE)
  write.xlsx(audi_CPO_exitclicks_outbound, file = file_name, 
             sheetName="exit_clicks", append=TRUE,row.names = FALSE)
  write.xlsx(weighted_average_dwell_time, file = file_name, 
             sheetName="weighted_average_dwell_time", append=TRUE,row.names = FALSE)
  