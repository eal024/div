

library(tidyverse)


vec <- c(1.5:10.1)

# Example: two functions
fpower <- function(x, p = 2) x^p
fround <- function(x, d){ round(x, digits = d ) } 

#
fround( fpower(vec, p = 2), d = 0)

# or
vec |> fpower(p = 3) |> fround(d = 1)

# Alternativ
power_round <- compose( fround,fpower)

power_round( vec)


# Trick: Is x in y
4 %in% vec

y <- 1:100
test <- 4

test %in% y
y[y %in% test]

# For mininal changing of functinal cals
round_no_digits <- partial(round, digits = 0)

test( 1.4:9.2)
