

#
library(tidyverse)
library(data.table)

df <- readxl::read_excel("data/2024-10-07 innvandring_pensjonsforliket.xlsx", skip = 2) |> 
    janitor::clean_names()

# Klargj??re
df1 <- df |> 
    setnames( c("kjonn", "alder", "kategori", "alternativ", "ar", "antall")) |>
    fill( c(kjonn, alder, kategori, alternativ), .direction = "down") |> 
    mutate(
        ar = as.numeric(ar),
        alder = str_remove(alder, " ??r")
    )



# Summerte antall
df_summert <- df1 |> 
    group_by(
        alder, ar
    ) |> 
    summarise(
        antall = sum(antall)
    )


df_summert |>
    filter( alder %in%  as.character(c(67:70)) ) |> 
    pivot_wider( names_from = ar, values_from = antall) |> 
    writexl::write_xlsx( "data_export/2024-10-07 pivot_wider_alder_innvandrere.xlsx")
    