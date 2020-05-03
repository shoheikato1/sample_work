# this is cross-search speciic file
install.packages("RGA")
library(RGA)
library(sqldf)

#2: Download References#

ga_token <- authorize(client.id = '31019866036-gna21un48frn4qq6j288e159gdb1om88.apps.googleusercontent.com',
                      client.secret = 'nQ-logyzXwVArBKfrYX43zJZ')

all_dim <- list_dimsmets()
cust_dim <- list_custom_dimensions('10401800','UA-10401800-37')
cust_met <- list_custom_metrics('10401800','UA-10401800-37')
segments <- list_segments(start.index = NULL, max.results = NULL)
OEM_segments <- segments[,3:2,]

#3: Set parameters
duration <- 'day'

startd <- '2018-10-01'
endd <- '2018-10-01'


#4: List of segments
no.1 <-Ford_F_150 <- 'gaid::kVLOD7rjSL2uzIA5Yg8bBQ'
no.2 <-Ford_Explorer <- 'gaid::-1NT9AB-RwaqEURxgs-m3g'
no.3 <-Ford_Ecosport <-'gaid::1gx0cnj-RbGT6cLH04HuNg'
no.4 <-Ford_Escape <-'gaid::X7NpYfG_SZKrdL3CfhFHUQ'

#4: Create reports - model level

##########################################################################################################
cross_unique_search_desktop_no.1 <- get_ga(profileId = 'ga:112082609', start.date = startd, end.date = endd
                                ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                ,metrics='ga:metric1'
                                ,sort='ga:dimension59,ga:dimension60'
                                ,segment = no.1
                                ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                ,token = ga_token
                                ,fetch.by= duration)

cross_unique_search_mDot_no.1 <- get_ga(profileId = 'ga:112044696', start.date = startd, end.date = endd
                                        ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                        ,metrics='ga:metric1'
                                        ,sort='ga:dimension59,ga:dimension60'
                                        ,segment = no.1
                                        ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                        ,token = ga_token
                                        ,fetch.by= duration)

cross_unique_search_iOS_no.1 <- get_ga(profileId = 'ga:113592302', start.date = startd, end.date = endd
                                       ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                       ,metrics='ga:metric1'
                                       ,sort='ga:dimension59,ga:dimension60'
                                       ,segment = no.1
                                       ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                       ,token = ga_token
                                       ,fetch.by= duration)

cross_unique_search_Android_no.1 <- get_ga(profileId = 'ga:113588605', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.1
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)


cross_unique_search_desktop_no.1$mob_or_desk <- "Desktop"
cross_unique_search_mDot_no.1$mob_or_desk <- "Mobile"
cross_unique_search_iOS_no.1$mob_or_desk <- "Mobile"
cross_unique_search_Android_no.1$mob_or_desk <- "Mobile"

cross_unique_search_no.1 <- rbind(cross_unique_search_desktop_no.1,cross_unique_search_mDot_no.1,cross_unique_search_iOS_no.1,cross_unique_search_Android_no.1)

cross_unique_search_no.1$base_model <- "Ford F-150"
##############################################################################################


##########################################################################################################
cross_unique_search_desktop_no.2 <- get_ga(profileId = 'ga:112082609', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.2
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)

cross_unique_search_mDot_no.2 <- get_ga(profileId = 'ga:112044696', start.date = startd, end.date = endd
                                        ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                        ,metrics='ga:metric1'
                                        ,sort='ga:dimension59,ga:dimension60'
                                        ,segment = no.2
                                        ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                        ,token = ga_token
                                        ,fetch.by= duration)

cross_unique_search_iOS_no.2 <- get_ga(profileId = 'ga:113592302', start.date = startd, end.date = endd
                                       ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                       ,metrics='ga:metric1'
                                       ,sort='ga:dimension59,ga:dimension60'
                                       ,segment = no.2
                                       ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                       ,token = ga_token
                                       ,fetch.by= duration)

cross_unique_search_Android_no.2 <- get_ga(profileId = 'ga:113588605', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.2
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)


cross_unique_search_desktop_no.2$mob_or_desk <- "Desktop"
cross_unique_search_mDot_no.2$mob_or_desk <- "Mobile"
cross_unique_search_iOS_no.2$mob_or_desk <- "Mobile"
cross_unique_search_Android_no.2$mob_or_desk <- "Mobile"

cross_unique_search_no.2 <- rbind(cross_unique_search_desktop_no.2,cross_unique_search_mDot_no.2,cross_unique_search_iOS_no.2,cross_unique_search_Android_no.2)

cross_unique_search_no.2$base_model <- "Explorer"

##############################################################################################


##########################################################################################################
cross_unique_search_desktop_no.3 <- get_ga(profileId = 'ga:112082609', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.3
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)

cross_unique_search_mDot_no.3 <- get_ga(profileId = 'ga:112044696', start.date = startd, end.date = endd
                                        ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                        ,metrics='ga:metric1'
                                        ,sort='ga:dimension59,ga:dimension60'
                                        ,segment = no.3
                                        ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                        ,token = ga_token
                                        ,fetch.by= duration)

cross_unique_search_iOS_no.3 <- get_ga(profileId = 'ga:113592302', start.date = startd, end.date = endd
                                       ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                       ,metrics='ga:metric1'
                                       ,sort='ga:dimension59,ga:dimension60'
                                       ,segment = no.3
                                       ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                       ,token = ga_token
                                       ,fetch.by= duration)

cross_unique_search_Android_no.3 <- get_ga(profileId = 'ga:113588605', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.3
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)


cross_unique_search_desktop_no.3$mob_or_desk <- "Desktop"
cross_unique_search_mDot_no.3$mob_or_desk <- "Mobile"
cross_unique_search_iOS_no.3$mob_or_desk <- "Mobile"
cross_unique_search_Android_no.3$mob_or_desk <- "Mobile"

cross_unique_search_no.3 <- rbind(cross_unique_search_desktop_no.3,cross_unique_search_mDot_no.3,cross_unique_search_iOS_no.3,cross_unique_search_Android_no.3)

cross_unique_search_no.3$base_model <- "EcoSport"

##############################################################################################


##########################################################################################################
cross_unique_search_desktop_no.4 <- get_ga(profileId = 'ga:112082609', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.4
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)

cross_unique_search_mDot_no.4 <- get_ga(profileId = 'ga:112044696', start.date = startd, end.date = endd
                                        ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                        ,metrics='ga:metric1'
                                        ,sort='ga:dimension59,ga:dimension60'
                                        ,segment = no.4
                                        ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                        ,token = ga_token
                                        ,fetch.by= duration)

cross_unique_search_iOS_no.4 <- get_ga(profileId = 'ga:113592302', start.date = startd, end.date = endd
                                       ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                       ,metrics='ga:metric1'
                                       ,sort='ga:dimension59,ga:dimension60'
                                       ,segment = no.4
                                       ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                       ,token = ga_token
                                       ,fetch.by= duration)

cross_unique_search_Android_no.4 <- get_ga(profileId = 'ga:113588605', start.date = startd, end.date = endd
                                           ,dimensions='ga:dimension59,ga:dimension60,ga:dimension49'
                                           ,metrics='ga:metric1'
                                           ,sort='ga:dimension59,ga:dimension60'
                                           ,segment = no.4
                                           ,filter='ga:dimension60!=not used;ga:dimension59!=not used;ga:dimension49!=not used;ga:dimension49==2018,ga:dimension49==2019'
                                           ,token = ga_token
                                           ,fetch.by= duration)


cross_unique_search_desktop_no.4$mob_or_desk <- "Desktop"
cross_unique_search_mDot_no.4$mob_or_desk <- "Mobile"
cross_unique_search_iOS_no.4$mob_or_desk <- "Mobile"
cross_unique_search_Android_no.4$mob_or_desk <- "Mobile"

cross_unique_search_no.4 <- rbind(cross_unique_search_desktop_no.4,cross_unique_search_mDot_no.4,cross_unique_search_iOS_no.4,cross_unique_search_Android_no.4)

cross_unique_search_no.4$base_model <- "Escape"
##############################################################################################


#Combine reports
cross_unique_search <- rbind(cross_unique_search_no.1,cross_unique_search_no.2,cross_unique_search_no.3,cross_unique_search_no.4)

colnames(cross_unique_search) <- c("Make","Model","Year","Total Search","mob_or_desk","base_model")

#colnames(cross_unique_search_Desktop) <- c("Make","Model","Unique Searches")
write.csv(cross_unique_search,"C:\\users\\skato\\desktop\\cross_unique_search_Ford2.csv",row.names = FALSE)
