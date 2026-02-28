

# The data from: 


Sys.setlocale("LC_CTYPE")
library(openxlsx)
library(httr)
library(tidyverse)

# Data
url1 <- "https://www.nav.no/_/attachment/download/a83b738d-711c-40b7-a5c0-c0c49ea9d953:89d3a5cbf42beadfd19654dbe2f237b2596977a1/PST311%20Nye%20Mottakere%20av%20uf%C3%B8retrygd.%20Alder.%20Kj%C3%B8nn_2023_08"
url2 <- "https://www.nav.no/_/attachment/download/edc9253b-ee64-4f97-9ecc-10b96b7d2976:9bcb65d662e43cd867e31c8cd98911954de6acd7/PST311_Nye_Mottakere_av_uf%C3%B8retrygd._Alder._Kj%C3%B8nn._2022_12"
url3 <- "https://www.nav.no/_/attachment/download/10f21377-9951-4741-8f0e-ac4de460300a:dbcc8da57bf68539a38ef280ccf1cd0206b25fa8/PST311_Nye_Mottakere_av_uf%C3%B8retrygd._Alder._Kj%C3%B8nn._2021_12"

data_list <- lapply( list(url1, url2, url3), function(x) openxlsx::read.xlsx( paste0(x, ".xlsx"), sheet = 2, startRow = 8)) |> 
    set_names( c(2023, 2022, 2021))

fun_wrangle <- function(df){
    df |> 
    rename( kjonn = X1, alder = X2) |> 
        fill( kjonn, .direction = "down") |> 
        mutate( kjonn = ifelse( is.na(kjonn), "samlet", kjonn),
                alder = str_remove(alder, "??r") |> str_trim(side = "both")
        ) |> 
        filter( !is.na(alder), !str_detect(alder, "alt") ) |>
        pivot_longer( -c(kjonn,alder)) 
}

df <- map( data_list, function(x) fun_wrangle(x)) |> 
    bind_rows( .id = "id") 



df_mnd <- tibble( name = c("Januar", "Februar", "Mars", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Desember"),
        nr   = 1:12
        )

df1 <- df |> 
    left_join(df_mnd, join_by(name) ) |> 
    mutate( date = paste0(id,"-",
                          ifelse(nr<10, paste0("0",nr), nr)
                          ) |> ym() ) |> 
    select(id, date, kjonn, alder, value) |> 
    mutate( value= as.numeric(value))



df1 |>
    arrange(kjonn ,alder, date) |> 
    filter( kjonn == "samlet", alder != "Uoppgitt") |> 
    ggplot( aes(y = value, x = date ) ) + 
    geom_line() +
    facet_wrap(~alder, scales = "free") +
    labs( title = "Nye mottakere av uforetrygd, per maaned fordelt etter aldersgruppe")
    
    
    

