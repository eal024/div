

# bib and packages
library(httr)
library(jsonlite)
library(tidyverse)
library(rjstat)

# 07459: Befolkning, etter kjønn, alder, statistikkvariabel og år
# https://www.ssb.no/statbank/table/07459/tableViewLayout1/

url <- "https://data.ssb.no/api/v0/no/table/07459/"

# API-spørring (Kvinner og menn, alder 18 til 67 år, hele landet)
source(here::here("appendix.R"), encoding = 'UTF-8')

temp <- POST(url , body = api_table_population_age, encode = "json", verbose())


#
data <- fromJSONstat(content(temp, "text")) |> janitor::clean_names()


#
data_1 <- as_tibble(data) |> select(kjonn,alder, ar, value) 


#
data_2 <- data_1 |>
    mutate( 
        alder = str_sub(str_trim(alder), start = 1, end = 2 ) |> as.numeric() 
    ) |> 
    select(-kjonn) |>
    group_by(  alder, ar) |> 
    summarise( value = sum(value) |> as.numeric(), .groups = "drop") |> 
    # Kun 11/12 av de på 18 medregnes. Og kun første mnd. av de som er 67 år.
    mutate( value = case_when( alder == 18  ~ value*(11/12),
                               alder == 67  ~ value*(1/12),
                               T ~ value) 
                               )

# Wide for å undersøke
data_2 |>  
    pivot_wider( 
        names_from = ar,
        values_from = value
        ) |> 
    janitor::clean_names() |>
    writexl::write_xlsx( str_c("data_export/", lubridate::today(), " faktisk_befolkning.xlsx") )

# Totalt antall     
# data_2 |> group_by(ar) |>  summarise( antall = sum(value))    


# data_2 |> writexl::write_xlsx( str_c("data_export/", lubridate::today(), " faktisk_befolkning.xlsx") )


    
