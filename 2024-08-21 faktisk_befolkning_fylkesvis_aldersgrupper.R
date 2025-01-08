
# https://www.ssb.no/statbank/table/07459/tableViewLayout1/
# 07459: Befolkning, etter region, alder, statistikkvariabel, ??r og kj??nn
library(httr)
library(rjstat)
library(rjstat)
source(here::here("appendix.R"))

# Data fra tabell
url <- "https://data.ssb.no/api/v0/no/table/07459/"
temp <- POST(url , body = json_api_b_fylkesvis_alder, encode = "json", verbose())
data <- fromJSONstat(content(temp, "text")) |> janitor::clean_names() 

names(data) <- c("region", "kjonn", "alder", "stat", "ar", "value")

# KlargjC8re data
data1 <- data |> # names()
    subset( 
        select = c( "region", "kjonn", "alder", "ar", "value"),
    ) |> 
    transform(
        kjonn = ifelse( kjonn == "Menn", "M", "K"),
        alder = str_remove_all(alder, " ??r| eller eldre")  |> as.numeric(),
        ar    = as.numeric(ar)
    )  |>
    tibble::as_tibble()


data2 <- data1 |> 
    summarise( 
        value = sum(value), .by = c("region", "alder", "ar")
    )

# Spesifikk for utviklingstrekk kapittel 2655
data3 <- data2 |>
    subset( 
        alder  %in% c(18:67)
    )  


# Excel-vennlig fremvisning
data4 <- tidyr::pivot_wider( data3, names_from = ar, values_from = value)

data4 |> writexl::write_xlsx("data_export/2024-08-21 faktisk_befolkningsutvikling_fylkesvis.xlsx")

