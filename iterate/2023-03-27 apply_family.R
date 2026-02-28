
library(tidyverse)

#
df <- data.frame( a = 1, b = 2, c = "a", d = "b", e = 4)

df

# find numeric columns
sapply(df, is.numeric)

map_lgl(df, is.numeric)

# Transform numeric column

num_cols <- sapply(df, is.numeric)

df[ , num_cols] <- lapply(df[ , num_cols], \(x) x*2)

# Stricter version than simple apply (sapply)
vapply(df, function(x) is.numeric(x), FUN.VALUE = logical(1))

# tapply
diamonds |> 
    group_by(cut) |> 
    summarise( price = mean(price)
               )


stat <- tapply( diamonds$price, diamonds$cut, function(x) mean(x))

tibble( name = names(stat), stat)





