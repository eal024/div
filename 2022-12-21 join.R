

# install development version
# pak::pak("tidyverse/dplyr")
library(tidyverse)

df <- tibble( navn   = c("E", "T", "C") |> rep(10),
              region =  sample( x = 1:3, replace = T, size = 30),
              cost = rnorm(n = 3*10, 100, 10)
)

# grouping by .by 
df |> summarise( cost = mean(cost), .by = navn)
df |> summarise( cost = mean(cost), .by = c(navn, region)) |> arrange( navn, region)

# Slice can also use .by
df |> arrange( region, cost) |> slice( 1:2, .by = region) 


# join functions ----------------------------------------------------------

df1 <- tibble( x_id = c(1,2,2), region = c("A","B", "A"), x = c(5,10,4)  )
df2 <- tibble( y_id = c(2,1,2), region = c("A","A", "C"), y = c(12,8,7)  )

df1 |> left_join(df2, join_by(x_id == y_id, region))

df1 |> left_join(df2 |> rename(x_id = y_id), by = c("x_id","region"))

#




# Sorting -----------------------------------------------------------------


ll <- c("A", "b", "c", "C", "B", "a")


str_sort(ll)

tibble( ll) |> arrange( ll, .locale = "en")



# Reframe -----------------------------------------------------------------

table <- c("a","b", "d", "f")

df <- tibble( g = c(1,1,1,2,2,2,2), x = c("e", "a", "b", "c", "f", "d", "a"))

df |> summarise( x = intersect(x, table), .by = g )

df |> reframe(x = intersect(x, table), .by = g)










