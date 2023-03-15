
library(tidyverse)
dir("data")
Sys.setlocale("LC_CTYPE")

dat <- readxl::read_excel("data/excel_tabeller.xlsx")


fun_rens <- function(x) str_remove(x, "[0-9]")

dat |> 
    mutate( stat = c("estimate", "std.dev") |> rep( nrow(dat)/2 )  ) |> 
    relocate( stat, .before = ??r) |> 
    pivot_longer(-c(type,stat,??r)) |> 
    arrange( type,name,??r) |> 
    mutate( value = map_chr( str_extract_all(value, "[0-9]" ), ~ str_c(.x, collapse="") ) |> as.numeric() ) |> 
    pivot_wider( names_from = ??r, values_from = value) |> 
    group_split(type) |> 
    writexl::write_xlsx("data_export/tabeller.xlsx")
    
    

