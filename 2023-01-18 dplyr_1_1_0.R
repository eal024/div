

# 
library(tidyverse) # Testversion of dplyr

# Data
expenses <- tibble(
    id = c(1, 2, 1, 3, 1, 2, 3),
    region = c("A", "A", "A", "B", "B", "A", "A"),
    cost = c(25, 20, 19, 12, 9, 6, 6)
)

# New group_by -> .by, which also ungroup after use
expenses |> summarise( cost = mean(cost), .by = region)

# work also with slice, mutate 
expenses |> slice( 1:2, .by = region)

# Joing improvements
df1 <- tibble(x_id = c(1, 2, 2), region = c("A", "B", "A"), x = c(5, 10, 4))
df2 <- tibble(y_id = c(2, 1, 2), region = c("A", "A", "C"), y = c(12, 8, 7))

df1
df2

#
left_join(df1, df2, join_by(x_id == y_id, region))
left_join(df1, df2, by = c("x_id" = "y_id", "region"))

# Example two
parties <- tibble(
    q = 1:4,
    party = clock::date_parse(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03"))
)

# Employment
employees <- tibble(
    name = wakefield::name(100),
    birthday = clock::date_parse("2022-01-01") + (sample(365, 100, replace = TRUE) - 1)
)

# Logical statement in equation.
df_birthd_party <- employees[1:4,] |> 
    # If birthday is the same day or after the party
    left_join( parties, join_by(birthday >= party))

df_birthd_party
df_birthd_party |> mutate(index = 1:n(), .by =name) |> filter(index == 1 )

## Example above, keep only one obs
employees[1:4,] |> 
    # If birthday is the same day or after the party
    left_join( parties, join_by( closest( birthday >= party)) )
 










    
    




