

library(tidyverse)

# Example of a list with tweets
l <- list(
    en = list( 
    "is_retweet" = T,
    "user_id" = 1,
    "tweet" = "ABC"
    ),
    to = list( 
    "is_retweet" = T,
    "user_id" = 2,
    "tweet" = "DBC"
    ),
    tre = list( 
    "is_retweet" = F,
    "user_id" = 3,
    "tweet" = "ABC"
    )
)

map( l, "is_retweet") # Check if retweet
keep(l, "is_retweet") # keep if retweet

# Keep and extract
keep( l, "is_retweet") |> map("user_id")
l[map_lgl(l, "is_retweet")] |> map("user_id")  # Alternative

# compact and flattern

# compact: remove elements of a list. For ex. create a one dim. from a nested 
ll <- list( list( a = 1), list( b = 2))

flatten(ll)

# seval code steps
map(l, "tweet") |> flatten() |> compact() |> unlist() |> table() |> sort() |> tail()

# Simplify
fn_tbl <- compose( tail, sort, table, unlist, compact, flatten)

# Execute the example
map(l, "tweet") |> fn_tbl()