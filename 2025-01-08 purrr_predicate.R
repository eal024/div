
library(tidyverse)

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

# Alternativ to using every
map(
    map( all_visits, \(x) x > 200 ),
    \(x) {
        len = length(x)
        sum(x) == len
        }
    )

# Every
map( all_visits, \(x) every( x, \(x) x > 200 ) )

# Some:
map(
    map( all_visits, \(x) x > 200 ),
    \(x) {
        sum(x) > 0
    }
)

# Some:
map( all_visits, \(x) some( x, \(x) x > 200 ) )


# ----------------------------------

t <- 1
class(`t`)
class(`+`)
# pure function
# output depent on the input
# no side-effect (no change in envirment)

map( list(1,2), \(x) log( x))
map( list(1, 2, "a"), log)
map( list(1, 2, "a"), safely(log))

map(list(1, 2,3, "a"), safely(\(x) log(x))) |> 
    map("result")
