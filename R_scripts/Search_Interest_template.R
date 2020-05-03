# STEP0: Install Packages

#install.packages("RGA")
#install.packages("sqldf")
#install.packages("dplyr")

# Because iOS/Android views act funny if backtracked more than 13 months, only desktop and mdot 
# is considered for this analysis where 
# 2017-10-01 -- 2018-11-30 is term1 and 2017-04-01 -- 2017-09-30 is term 2


#1: activate RGA library
library(RGA)
library(sqldf)
library(dplyr)
library(readr)

#2: Download References

ga_token <- authorize(client.id = '31019866036-gna21un48frn4qq6j288e159gdb1om88.apps.googleusercontent.com',
                      client.secret = 'nQ-logyzXwVArBKfrYX43zJZ')

all_dim <- list_dimsmets()
cust_dim <- list_custom_dimensions('10401800','UA-10401800-37')
cust_met <- list_custom_metrics('10401800','UA-10401800-37')
segments <- list_segments(start.index = NULL, max.results = NULL)
OEM_segments <- segments[,3:2,]

duration <- 'day'

startD <- '2019-03-01'
endD <- '2019-03-30'


#STEP3: CREATE REPORT

search_interest_pv_desktop_fuel <- get_ga(profileId = 'ga:112082609', start.date = startD, end.date = endD
                                          ,dimensions='ga:date,ga:yearMonth,ga:region,ga:dimension51,ga:dimension59,ga:dimension60,ga:dimension53'
                                          ,metrics='ga:metric1'
                                          ,sort="ga:metric1"
                                          #,segment = ##
                                          ,filter='ga:country==Canada;ga:dimension47=@Cars'
                                          ,token = ga_token
                                          ,fetch.by= duration)


search_interest_pv_mdot_fuel <- get_ga(profileId = 'ga:112044696', start.date = startD, end.date = endD
                                       ,dimensions='ga:date,ga:yearMonth,ga:region,ga:dimension51,ga:dimension59,ga:dimension60,ga:dimension53'
                                       ,metrics='ga:metric1'
                                       ,sort="ga:metric1"
                                       #,segment = ##
                                       ,filter='ga:country==Canada;ga:dimension47=@Cars'
                                       ,token = ga_token
                                       ,fetch.by= duration)

search_interest_pv_ios_fuel <- get_ga(profileId = 'ga:113592302',  start.date = startD, end.date = endD
                                      ,dimensions='ga:date,ga:yearMonth,ga:region,ga:dimension51,ga:dimension59,ga:dimension60,ga:dimension53'
                                      ,metrics='ga:metric1'
                                      ,sort="ga:metric1"
                                      #,segment = ##
                                      ,filter='ga:country==Canada;ga:dimension47=@Cars'
                                      ,token = ga_token
                                      ,fetch.by= duration)

#iOS data is corrupted for Jan - Feb 2017

search_interest_pv_android_fuel <- get_ga(profileId = 'ga:113588605', start.date = startD, end.date = endD
                                          ,dimensions='ga:date,ga:yearMonth,ga:region,ga:dimension51,ga:dimension59,ga:dimension60,ga:dimension53'
                                          ,metrics='ga:metric1'
                                          ,sort="ga:metric1"
                                          #,segment = ##
                                          ,filter='ga:country==Canada;ga:dimension47=@Cars'
                                          ,token = ga_token
                                          ,fetch.by= duration)

search_interest_pv_desktop_fuel$mob_or_desk <- "Desktop"
search_interest_pv_mdot_fuel$mob_or_desk <- "Mobile"
search_interest_pv_ios_fuel$mob_or_desk <- "Mobile"
search_interest_pv_android_fuel$mob_or_desk <- "Mobile"


search_interest_pv_desktop_fuel$platform <- "Desktop"
search_interest_pv_mdot_fuel$platform <- "mDOT"
search_interest_pv_ios_fuel$platform <- "iOS"
search_interest_pv_android_fuel$platform <- "Android"

search_interest_data_201903<- rbind(search_interest_pv_desktop_fuel,search_interest_pv_mdot_fuel,search_interest_pv_ios_fuel,search_interest_pv_android_fuel)

search_interest_data_backup <- search_interest_data

search_interest_data_refine <- sqldf(
  "select
  yearMonth,
  dimension51,
  dimension59,
  dimension60,
  dimension59 || ' ' || dimension60 as make_model,
  dimension53,
  sum(metric1) as total_search,
  mob_or_desk,
  platform
  
  from search_interest_data
  
  group by
  yearMonth,
  dimension51,
  dimension59,
  dimension60,
  dimension59 || ' ' || dimension60,
  dimension53,
  mob_or_desk,
  platform
  ")

colnames(search_interest_data_refine) <- c("month","fuel_type","make","model","make_model","keyword_search",
                                           "total_search","mob_or_desk","platform")

###########################
# FUEL SEGMENT
###########################

####### First import fuel_type_categorization list & list of evs
# fuel by fuel_type
unique(search_interest_)

search_interest_data_refine_fuel <-search_interest_data_refine

library(readr)
fuel_type_categorization <- read_csv("Fuel_type_categorization_2.csv")
list_of_evs <- read_csv("List_of_EVs.csv")

# turn imported data into df

fuel_type_categorization <- as.data.frame(fuel_type_categorization)
list_of_evs <- as.data.frame(list_of_evs)

# turn all the data into lowercase

for (i in 1:ncol(fuel_type_categorization)) {
  fuel_type_categorization[[i]] <- tolower(fuel_type_categorization[[i]])
}

for (i in 1:ncol(list_of_evs)) {
  list_of_evs[[i]] <- tolower(list_of_evs[[i]])
}

# for keyword_search, we have some invalid character, so change data format
search_interest_data_refine_fuel$keyword_search<-iconv(search_interest_data_refine_fuel$keyword_search, 'UTF-8', 'ASCII')
search_interest_data_refine_fuel$make<-iconv(search_interest_data_refine_fuel$make, 'UTF-8', 'ASCII')
search_interest_data_refine_fuel$model<-iconv(search_interest_data_refine_fuel$model, 'UTF-8', 'ASCII')
search_interest_data_refine_fuel$make_model<-iconv(search_interest_data_refine_fuel$make_model, 'UTF-8', 'ASCII')
# lower case all data for the main data table

search_interest_data_refine_fuel$fuel_type <- tolower(search_interest_data_refine_fuel$fuel_type)
search_interest_data_refine_fuel$make <- tolower(search_interest_data_refine_fuel$make)
search_interest_data_refine_fuel$model <- tolower(search_interest_data_refine_fuel$model)
search_interest_data_refine_fuel$make_model <- tolower(search_interest_data_refine_fuel$make_model)
search_interest_data_refine_fuel$keyword_search <- tolower(search_interest_data_refine_fuel$keyword_search)
search_interest_data_refine_fuel$mob_or_desk <- tolower(search_interest_data_refine_fuel$mob_or_desk)
search_interest_data_refine_fuel$platform <- tolower(search_interest_data_refine_fuel$platform)

# alternatively
for (i in 2:6){
  search_interest_data_refine_fuel[[i]] <- tolower(search_interest_data_refine_fuel[[i]])
}

###### LEFT JOIN 3 DFs

search_interest_data_refine_fuel_temp_categorization <- merge(search_interest_data_refine_fuel, 
                                                              fuel_type_categorization, by.x = "fuel_type", by.y = "fuel_type"
                                                              , all.x=TRUE)
# all.x = TRUE - LEFT JOIN / all.y = TRUE - RIGHT JOIN / all = TRUE - OUTERJOIN
search_interest_data_refine_fuel_temp_ev_category <- merge(search_interest_data_refine_fuel, list_of_evs,
                                                           by.x = "make_model", by.y = "make_model"
                                                           , all.x=TRUE)

search_interest_data_refine_fuel_final <- merge(search_interest_data_refine_fuel, 
                                                fuel_type_categorization, by.x = "fuel_type", by.y = "fuel_type"
                                                , all.x=TRUE) %>% merge(., list_of_evs,
                                                                        by.x = "make_model", by.y = "make_model"
                                                                        , all.x=TRUE)


###### CATEGORIZE KEYWORD SEARCH PHRASES
search_interest_data_refine_fuel_final$fuel_type_v2 <- NA
# electric
index<-grepl("electric",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'electric'

index<-grep("ev",search_interest_data_refine_fuel_final$keyword_search,value = TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'electric'

# PHEV
index<-grepl("plug-in",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'PHEV'

index<-grepl("PHEV",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'PHEV'

#hybrid
index<-grepl("hybrid",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'hybrid'
index<-grepl("hv",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'hybrid'

#Natural Gas
index<-grepl("natural gas",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'natural gas'

#Diesel
index<-grepl("diesel",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'diesel'

#Gas
index<-grepl("gas",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'gasoline'
index<-grepl("petro",search_interest_data_refine_fuel_final$keyword_search,fixed=TRUE)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'gasoline'


index <- search_interest_data_refine_fuel_final$fuel_type_v2 = NA
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'unknown'

# Drop the columns of the dataframe

index <- is.na(search_interest_data_refine_fuel_final$fuel_category)
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'unknown'
index <- search_interest_data_refine_fuel_final$fuel_type_v2.is.na
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'unknown'
index <- search_interest_data_refine_fuel_final$fuel_type_2.is.na
search_interest_data_refine_fuel_final$fuel_type_v2[index]<-'unknown'


###########################
# CAR SEGMENT
##########################

#IMPORT SEGMENT
car_segment <- read.csv("C:\Users\skato\Desktop\New_data.csv")

car_segment$Make<-as.character(car_segment$Make)
car_segment$Model<-as.character(car_segment$Model)
car_segment$Segment<-as.character(car_segment$Segment)
car_segment$Category<-as.character(car_segment$Category)

car_segment[[1]] <- tolower(car_segment[[1]])
car_segment[[2]] <- tolower(car_segment[[2]])
car_segment[[3]] <- tolower(car_segment[[3]])
car_segment[[4]] <- tolower(car_segment[[4]])
colnames(car_segment) <- c("make","model","segment","category")


#IMPORT EVLIST

#CLEANING RAW FILE

search_interest_data_Venky_refine$keyword_search <- iconv(search_interest_data_Venky_refine$keyword_search, 'UTF-8', 'ASCII')

search_interest_data_Venky_refine[[1]] <- tolower(search_interest_data_Venky_refine[[1]])
search_interest_data_Venky_refine[[2]] <- tolower(search_interest_data_Venky_refine[[2]])
search_interest_data_Venky_refine[[3]] <- tolower(search_interest_data_Venky_refine[[3]])
search_interest_data_Venky_refine[[4]] <- tolower(search_interest_data_Venky_refine[[4]])
search_interest_data_Venky_refine[[5]] <- tolower(search_interest_data_Venky_refine[[5]])
search_interest_data_Venky_refine[[6]] <- tolower(search_interest_data_Venky_refine[[6]])
search_interest_data_Venky_refine[[7]] <- tolower(search_interest_data_Venky_refine[[7]])
search_interest_data_Venky_refine[[8]] <- tolower(search_interest_data_Venky_refine[[8]])
colnames(search_interest_data_Venky_refine) <- c("month","fuel_type","make","model","keyword_search","total_search","mob_or_desk","platform")

search_interest_data_Venky_refine_segment <- sqldf(
  "select
  month,
  a.make,
  a.model,
  segment as segment,
  category as category,
  sum(total_search) as total_search,
  mob_or_desk,
  platform
  
  from search_interest_data_Venky_refine a
  left join car_segment b ON a.make = b.make AND a.model = b.model
  
  group by
  month,
  a.make,
  a.model,
  segment,
  category,
  mob_or_desk,
  platform
  ")

write.csv(search_interest_Katie_201903_v3,"C:\\users\\skato\\desktop\\search_interest.csv",row.names = FALSE)
