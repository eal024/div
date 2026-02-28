
# 14288: Framskrevet folkemengde 1. januar, etter region, kj??nn, alder, år og statistikkvariabel
library(httr)
library(rjstat)
library(rjstat)
source(here::here("appendix.R"))

# Data fra tabell
url <- "https://data.ssb.no/api/v0/no/table/14288/"
temp <- POST(url , body = json_api_butvikling_fylkesvis, encode = "json", verbose())
data <- fromJSONstat(content(temp, "text")) |> janitor::clean_names() 

names(data) <- c("region", "kjonn", "alder", "alt", "ar", "value")

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

# Utprint: Hovedalternativet for kvinner 18 til 44 C%r.
# list_df <- group_split(data4, region) 

navn <- map_chr(list_df, \(x) unique(x$region) )

list_df <- set_names(list_df, navn)

list_df |> writexl::write_xlsx("data_export/2024-08-19 befolkningsutvikling_fylkesvis.xlsx")
data4 |> writexl::write_xlsx("data_export/2024-08-19 befolkningsutvikling_fylkesvis_samlet.xlsx")

