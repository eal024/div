

library(tidyverse)


df <- tibble( col1 = 1:10, col2 = 2:11, col3 = 11:20, col4 = rnorm(10, 15, 1))

vars <- c("col2", "col3", "col4")


method1 <- function(){
    df %>%
    mutate( new = pmap( select(., all_of(vars)), pmax, na.rm = T) ) |> 
    unnest(new)
    }

    
method2 <- function(){
    df %>% 
        mutate(
            new = reduce( select(., all_of(vars)), pmax, na.rm = T)
        )
    
}


microbenchmark::microbenchmark(
    m1 = method1(),
    m2 = method2()
)
