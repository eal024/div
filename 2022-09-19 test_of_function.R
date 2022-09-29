


# test of functions

library(tidyverse)

#
df <- tibble( fk = c(1:4), verdi  = c(1,2,3,NA), flere = c(NA,NA,1,2))

# simple example
df |> mutate( se  = coalesce(verdi, 0)) 

# using across
df |> mutate( across( .cols = everything(), .fns = function(x) coalesce(x,0)))



# across and sum statistics ------------------------------------------------

#
as_tibble( mtcars |> rownames_to_column() ) |> 
    group_by( rowname ) |> 
    summarise( 
        across( .cols = where(is.numeric),
                .fns = list( mean = mean, sd = sd, median = median ),
                .names = "{.fn}_{.col}"
        )
    ) |> 
    glimpse()

