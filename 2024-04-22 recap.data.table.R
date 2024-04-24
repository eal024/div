
library(data.table)

dt <- my_data <- data.table(
    ID = 1:10,
    Var_1 = sample(1:100, 10),
    Var_2 = rnorm(10, mean = 50, sd = 10),
    Var_3 = rnorm(10, mean = 10, sd = 2),
    Cat_Var_1 = sample(letters[1:3], 10, replace = TRUE),
    Cat_Var_2 = sample(letters[24:26], 10, replace = TRUE)
)


# 1) lapply and .SDcols -------------
cols <- c("Var_1", "Var_2")

# Create new variable 
dt[ , c( paste0("New_", cols)) := lapply(.SD, \(x) x/10), .SDcols = cols][]


# Aggreating by .SD

col_by <- c("Cat_Var_1")
col_sum <- cols

dt[ , lapply(.SD, \(x) sum(x)), by =  col_by , .SDcols = col_sum]
