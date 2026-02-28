



library(tidyverse)

# Data------------------------------------------------------------

# Personer og år
fk <- c(1:4)
ar <- c(2015:2023)

# Gen sim data
fn_gen_values <- function(n){ 
    sample(
         x = seq(from = 0, to = 2, by = .1), 
         size = n, 
         replace = T ,
         prob = c( 0.2, seq(from = 0, to = 1, length.out = length(seq(from = 0, to = 2, by = .1))-1 ) ) 
        ) 
    }

# Generetae data
df <- expand_grid( fk, ar) |> 
    mutate(
    AAP = fn_gen_values( nrow(df) ),
    dp =  fn_gen_values( nrow(df) )
    )  |> 
  ungroup()


#
teller <- sample( x = ar, size = length(fk), replace = T)


df1 <- df |> 
    left_join(
        tibble( fk = fk, teller = teller),
        join_by(fk)
    ) |> 
    mutate(
        teller = ar-teller 
    )


# pivotering-------------------------------------

# 1) ytelse
df2 <- df1 |>
    filter( teller < 0)  |> 
    select(-ar) |> 
    pivot_longer(c(AAP,dp)
    ) |> 
    arrange( fk, name, teller)



df3 <- unite( df2, "ytelse_ar" ,c(name, teller), sep = "_")

df4 <- df3 |> pivot_wider( names_from = ytelse_ar, values_from = value)

df5 <- df4 |> select( fk, matches("dp"), matches("AAP")) |> janitor::clean_names()

df5[is.na(df5)] <- 0

View(df5)

new_order <- sort(names(df5)[-1])

df6 <- df5 |> 
    select(fk, all_of(new_order) )


df6