
https://www.ben-johnston.co.uk/r-for-seo-part-2-packages-google-analytics-search-console/
# ## Install Single Package

# library(tidyverse)

# install.packages("googleAnalyticsR")

# library(googleAnalyticsR)

# install.packages("searchConsoleR")

# library(searchConsoleR)

# install.packages("googleAuthR")

# library(googleAuthR)

## Installing Multiple Packages

instPacks <- c("tidyverse", "googleAnalyticsR", "searchConsoleR", "googleAuthR")

lapply(instPacks, require, character.only = TRUE)

## Authorise Google Analytics

ga_auth()

## Find Google Analytics Accounts

gaAccounts <- ga_account_list()

viewID <- gaAccounts$viewId[7]

testData <- google_analytics(viewID, date_range = c("2022-02-01","2022-02-08"), metrics = "sessions")

GAData <- google_analytics(viewID, date_range =c("2022-02-01","2022-02-08"), metrics = c("sessions", "users", "pageviews", "bouncerate"))

## Adding Segments

GASegments <- ga_segment_list()

which(GASegments$name == "Organic Traffic")

orgSegment <- segment_ga4("orgSegment", segment_id = "gaid::-5")

GADataOrg <- google_analytics(viewID, date_range =c("2022-02-01","2022-02-08"), metrics = c("sessions", "users", "pageviews",                                                                                        "bouncerate"), segment= orgSegment)

## Date Range Dimension

GADataOrgDates <- google_analytics(viewID, date_range =c("2022-02-01","2022-02-08"), metrics = c("sessions", "users", "pageviews",                                                                                        "bouncerate"), dimensions = "date",segment= orgSegment)

## Dynamic Dates

GADataDynamicDates <- google_analytics(viewID, date_range =c("7DaysAgo","yesterday"), metrics = c("sessions", "users", "pageviews", "bouncerate"), dimensions = "date",segment= orgSegment)

## Search Console Data

scr_auth()

scData <- search_analytics("https://www.ben-johnston.co.uk", startDate = Sys.Date() -7, Sys.Date() -1, searchType = "web")

## Break By Date

scDataByDate <- search_analytics("https://www.ben-johnston.co.uk", startDate = Sys.Date() -7, Sys.Date() -1, searchType = "web", dimensions = "date")