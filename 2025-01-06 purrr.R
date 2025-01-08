# 
library(tidyverse)


# Data
fn_data <- function( n = sample(10:50, 1) ){
    tibble( 
        id = 1:n,
        age = sample( 18:80, n, replace = T),
        gender = sample( c("M", "F"), n, replace = T, prob = c(0.45,0.55))
    )
}

# creating a random dataset for each month
df <- tibble( mnd = month(1:12,label = T), data = map(1:12, \(x) fn_data()))
l_df <- df$data |> set_names(df$mnd)


# Keep and discard
l <- list( a = c(1:4), b = letters[1:4] |> as.factor(), c = c("bil", "hest") |> as.factor())

# Example
keep(l, is.factor)
discard(l, is.factor)

random_visit <- function(){ 
    return(sample( x = seq(from =100, to = 1000, by = 10), size = 7, replace = T )) 
}


# Liste med lister med antall. 
all_visits <- list(
    a = random_visit(),
    b = random_visit(),
    c = random_visit()
)

# Beholder kun de over 500
day <- c("mon", "tue", "wed", "thu", "fri", "sat", "sun")
all_visits <- map(
    all_visits, 
    \(x) set_names(x, day) 
)

# Med å komibinere navn og keep, blir det lettere å se
map(all_visits, \(x) keep(x, function(x) x > 500))


