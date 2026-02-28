

#
library(tidyverse)
library(collapse)

# Raw data: Helserelaterte bruk ytelser
df <- readxl::read_excel("data/Helserelaterte ytelser etter alder  Bosatt i Norge 2001-2023  60-66 aar.xlsx", skip = 4) |> 
    janitor::clean_names() 


# Bruker kun samlet bruk
df1 <- df[,1:3] |> 
    filter( !is.na(x1)) |> 
    mutate( alder  = ifelse( str_detect(x1, "??r"), x1, NA_real_) ) |> 
    fill( alder, .direction = c("down") ) |> 
    mutate( alder = ifelse( is.na(alder), "i alt", alder )) |> 
    filter( !is.na(antall_bosatte_2)) |> 
    rename(
        bosatte = antall_bosatte_2,
        hry = antall_hry_3,
        ar = x1
    ) |> 
    relocate(
        alder , .after = ar
    ) |> 
    mutate(
        across( .cols= c(ar,bosatte, hry), .fns = \(x) as.numeric(x) )
    )



#  Aggregerte data
df2 <- df1 |> 
    filter( alder != "i alt" ) |> 
    group_by(ar) |> 
    summarise(
        antall = sum(bosatte),
        hry = sum(hry)
    ) |> 
    mutate(
        andel = hry/antall
    ) 


# Tester joning data
microbenchmark::microbenchmark(
    collapse = function() {df1 |> join( df2, on = "ar")},
    dplyr    = function() {df1 |> left_join( df2,  join_by(ar))} 
)

library(data.table)

dt <- as.data.table(df1)
dt2 <- as.data.table(df2)

dt[ ar %in% c(2002:2005),,]
