

library(tidyverse)

numbers <- c(1:4) |> as.list()

accumulate( numbers, `+`)

cumsum(numbers)

reduce(numbers, `+`)

cumsum(numbers)[length(numbers)]

# Composing two finctions
add <- function(x) x +  1
square <- function(x) x^2
add_and_sq <- compose(  add , square )
map_dbl( numbers, \(x) add_and_sq(x))


# Composing several functions
app_fun <- function(x, ...) purrr::map_dbl( list(...), \(f) f(x))
app_fun <- function(x, ...) purrr::map_dbl(list(...), \(f) f(x))
app_fun(1:4, mean, median, sd)



# Example

# split the data by carb
test <- split(mtcars,mtcars$carb)

# For the first variable, for each, calcualte the statistics
map( map(test,1), \(x) app_fun( x,  mean,median, sd) |> set_names( c("mean", "m", "sd")) ) 


