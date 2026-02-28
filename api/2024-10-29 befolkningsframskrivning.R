
# 14288: Framskrevet folkemengde 1. januar, etter region, kj??nn, alder, år og statistikkvariabel
library(tidyverse)
library(httr)
library(rjstat)
library(rjstat)
source(here::here("appendix.R"))

# Data fra tabell
url <- "https://data.ssb.no/api/v0/no/table/14282/"
temp <- POST(url , body = json_api_befolkning, encode = "json", verbose())
data <- fromJSONstat(content(temp, "text")) |> janitor::clean_names( )

# Klargjøre data
data1 <- data |> 
    subset( 
        select = c( "alternativ", "statistikkvariabel", "kjonn", "alder", "ar", "value"),
    ) |>
    transform(
        kjonn = ifelse( kjonn == "Menn", "M", "K"),
        alder = str_remove_all(alder, " år| eller eldre")  |> as.numeric(),
        ar    = as.numeric(ar)
    )  |>
    tibble::as_tibble()

# Data
data2 <- data1 |> 
    summarise( 
        value = sum(value), .by = c( "alder", "ar")
               )

# Spesifikk for utviklingstrekk kapittel 2655
data3 <- data2 |>
    subset( 
        alder  %in% c(16:67)
    )  


# Excel-vennlig fremvisning
data4 <- tidyr::pivot_wider( data3, names_from = ar, values_from = value)

# Utprint: Hovedalternativet for kvinner 18 til 44 C%r.
# list_df <- group_split(data4, region) 

data4 |> writexl::write_xlsx("data_export/2024-10-29 befolking_samlet_hovedalternativ.xlsx")
