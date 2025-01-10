
# Iteration over rows and colunms
library(tidyverse)

mtcars <- as_tibble(mtcars)

# function over row or columns
apply( mtcars, MARGIN = 1, FUN = sum)
apply( mtcars, MARGIN = 2, FUN = sum)

# Alternativ: create a for loop
sum_row_nr <- function( row){
    s <- 0
    for( i in 1:length(mtcars[row,]) ){
        s <- s +  mtcars[row,i][[1]]
    }
    s   
}

# Test functionl
sum_row_nr(row = 2)

# Alternativ
map_dbl( 1:nrow(mtcars), \(row) sum_row_nr( row = row) )

# Performance
microbenchmark::microbenchmark(
    apply = apply( mtcars, MARGIN = 1, FUN = sum),
    self_made = map_dbl( 1:nrow(mtcars), \(row) sum_row_nr( row = row) ),
    alternaive_copilot = mtcars  |> split(1:nrow(mtcars ) )  |> map_dbl(\(x) sum( unlist(x )))
)

