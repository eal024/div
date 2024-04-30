

# data
head(mtcars)

# Data wrangling
(head(mtcars) |> 
    sort_by(~list(-mpg)) |> 
    subset( carb %in% c(1,2)) |> 
    transform( mpg_extra = mpg + 100) -> mtcars2)

# Summarise
mtcars2 |> 
    aggregate( . ~cyl, FUN = mean, data = _)



# Timning
library(microbenchmark)
library(tidyverse)

# 
dplyr <- function() {
    mtcars |> 
        arrange( desc(mpg)) |> 
        subset( carb %in% c(1,2)) |> 
        mutate(
            mgp_extra = mpg + 100
        ) |> 
        summarise_all( mean)
}

base <- function( ) {
    mtcars |> 
    sort_by(~list(-mpg)) |> 
    subset( carb %in% c(1,2)) |> 
    transform( mpg_extra = mpg + 100) |>    
    aggregate( . ~cyl, FUN = mean, data = _)
}

library(data.table)

data_table <- function() {
    as.data.table(mtcars)[ carb %in% c(1,2), mpg_extra := as.numeric(mpg) + 100.0,
    ][ order(mpg)][, lapply(.SD, mean) , by = cyl ]
}


microbenchmark(
    dplyr = dplyr(),
    base = base(),
    data.table = data_table()
)
