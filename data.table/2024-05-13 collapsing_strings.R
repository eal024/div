
# Collapsing variable into string, based on group 

# data example
df <- data.frame(
    CustomerID = c(1, 1, 2, 2, 3),
    Product = c("Apple", "Orange", "Banana", "Peach", "Grapes"),
    Quantity = c(2, 3, 1, 2, 1),
    stringsAsFactors = FALSE
)


# Base R
aggregate(Product ~ CustomerID, data = df, FUN = \(x) paste(x, collapse =  ", "))

# data.table
library(data.table)

dt <- as.data.table(df)
dt[ , .(Product = paste(Product, collapse = ", ")), by = CustomerID]


# Dplyr
library(tidyverse)

df |> 
    summarise(
        Product = paste(Product, collapse = ", "),
        .by = CustomerID
        )

# Alternative: Into variables
df |> 
    select(-Quantity) |> 
    group_nest(CustomerID) |> 
    unnest_wider( col = data ) |>
    unnest_wider( col = Product, names_sep = ", " ) 