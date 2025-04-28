
library(tidyverse)
library(data.table)

# Functional
map_filter <- function(){
    mtcars %>%
        split(1:nrow(.)) %>%
        keep(~ .x$mpg > 20) %>%
        discard(~ .x$hp < 100) %>%
        bind_rows()
        
}

dplyr <- function(){
    mtcars %>%
        filter( mpg > 20, hp > 100) |> 
        as_tibble()
}

dt <- as.data.table(mtcars)
d_t <- function(){
    dt[ mpg > 20, hp > 100,,] 
}



microbenchmark::microbenchmark(
    map = map_filter(),
    dplyr = dplyr(),
    d.t = d_t
)
