
# Handling list with different comp. that for ex. does not work with sum/log m,
# For. example factor or char.  

library(tidyverse)

# Example list
l <- list( a = c(1:10), b = letters[1:4], c = rnorm( n = 10, mean = 10, sd = 2))

# how sum works -- return an error
map( l, sum)

# safely: returning error and result
saf_sum <- safely(sum)
l_res <- map( l, saf_sum)
map(l_res, "result")

# possibly: only interessted in the result
poss_sum <- possibly(sum, otherwise = "NULL")
l_pos <- map(l, poss_sum)
keep( l_pos, function(x) x != "NULL")

## Return the name of the good ones:
f_not_null <- function(l){
    l |> 
        map( possibly( sum, otherwise = "NULL") ) |> 
        # remove the "NULL"
        discard( \(x) x == "NULL") |> 
        names()
}

# Keeping only the list which is ok (gives sum)
l[ names(l) %in% f_not_null( l = l)]



## Example of use of transpose
value <- list( 2,"a", 4, "b")

safe_log <- safely( \(x) log(x))
result <- map( value, safe_log)

keep( \(x) map(value, \(x) safe_log(x) ) == "result")

# Organisere listen etter elementene i sublisten
transpose( result )
b_list <- list( en = list(1,2), to = list(3,4))

# omgjore til 1: 1,3 og 2:2 og 4
b_list |> transpose()
