
# 
library(tidyverse)


# chapter 9: Functional: function as input, return vector

# Function as input f, return vector
ran <- function(f) f(runif(10))

# Exec.
ran(sd)
ran(sum)

# 9.1 the map
# call the function for each element in the vec
map(1:3, function(x) x*2)

# example alternativ
mtcars

n_unique <- function(x) length(unique(x))

map_int(mtcars, n_unique)
map_dbl(mtcars, mean)
map_chr(mtcars, mean)
map_lgl(mtcars, is.double)

# Return output with same length

# Base alternativ for returning spesific type
# vapply(list, function, FUN.VALUE = type, ...)
vapply(c(1:3), function(x) x*2, FUN.VALUE = double(1))


# Anonymous functions: Behind the scenes:
as_mapper(~length(unique(.x)))

# Example
x <- map(1:3, ~runif(2))

x


## Extracting from a list

x <- list(
    list(-1,x = 1, y = c(2), z = "a"),
    list(-2,x = 4, y = c(5,6), z = "B"),
    list(1, x = 1, y = 1:10)
)

# Alternativs
map(x,1)
map(x,"x")
map(x,"y")
map(x,"z")

map(x, list("y",2))


x[[1]][[1]]

for(i in 1:length(x)){print(x[[(2)]][i]) }
extract_list_el <- function(list,el){
    for(i in 1:length(list)){print(x[[(el)]][i]) }
}

extract_list_el(x, 3)


# another argument --------------------------------------------------------

x <- rcauchy(10)

# Want to trim c(0, 0.1, 0.2, 0.5)
mean(c(0.112,0.167,0.19), trim = 0)
mean(c(0.112,0.167,0.19), trim = 1)

#
trim <- c(0, 1,2,3)
map(trim, ~round(mean(x ),digits = .x )) |> head()

# making the function clearer
map(trim, function(trim) round(x, digits =   trim))



# Style -------------------------------------------------------------------

# Example using purrr: fitting model to each subgroup, extractiong coeff

# data: 3 df by cyl
by_cyl <- split(mtcars, mtcars$cyl)

#
map(by_cyl, function(x) {lm(mpg ~wt, data = x)} ) |> 
    map( coef) |> 
    map_dbl(2)

coef <- map(by_cyl, function(x) {lm(mpg ~wt, data = x)} ) |> 
    map(coef)  

coef_tbl <- map(by_cyl, function(x) {lm(mpg ~wt, data = x)} ) |> 
    map( summary) |>
    map(function(x) coef(x))  

tibble( 
        by_cyl   = names(by_cyl),
        estimate = map_dbl(coef_tbl, function(x) x[2,"Estimate"]),
        st.error = map_dbl(coef_tbl, function(x) x[2,"Std. Error"])
)    

vapply(coef, function(x) x[[2]], FUN.VALUE = double(1))

coef_tbl
vapply(coef_tbl, function(x) x[[2]], FUN.VALUE = double(1))
vapply(coef_tbl, function(x) x[[3]], FUN.VALUE = double(1))

# In a for-loop
for(i in 1:length(coef_tbl)){
    print(coef_tbl[[i]][2])
}



# map variants ------------------------------------------------------------

# same type of output -> input same taype

df <- data.frame( x = 1:4, y = 5:8)

map(df, ~.x*2) # list
modify(df, ~.x*2) # keep the output a data.frame
# modify return a copy

df$z <- letters[1:4]

# modify if
modify_if(df, ~is.numeric(.x),  ~.x*2 )

weighted.mean(c(1,2,3), w = c(2/3,0/3,1/3))

1*(2/3)+(2*(0/3))+3/3

# No output, only the sideeffects

# write to disck
# Print etc.

text_message <- function(name){
    cat("Hei ", name, "!\n", sep = "")
}

text_message(name = "Eirik")

liste_navn <-  c("Eirik", "Trym", "Ove")

map(liste_navn, function(x) text_message(x))
# Alternativ
walk(liste_navn, function(x) text_message(x))

# Saving to disk

temp <- tempfile()
dir.create("temp")

cyls <- split( mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)

# imap = for( i in seq_alng(xs))

# If first vector is unnamed, second arg. will be index:
imap_chr( iris, ~paste0("First value of: ",.y, " is ", .x[[1]]))

x <- map(1:3, ~sample(100, 10))

for(i in seq_along(x) ){print( max(x[[i]])) }
for(i in seq_along(x) ){cat( max(x[[i]]),"\n", sep = " ") }



# imap --------------------------------------------------------------------

a <- list( x = c(1,2,3),
      y = c("a", "b", "c"),
      navn = c("Eirik", "Trym", "ove")
      )

# Nested
b <- list( a = list(a = 1, b = c(1:5)),
           b = list(a = 2, b = c(6:10))
           )


# 
x <- map(1:6, ~sample(1000, 10))


#
imap(a, ~.x[[2]])
imap(b, ~.x[[2]][[2]])

# index by input
library(rlang)
imap_chr( x, ~glue::glue("Highest value of ", .y, " is ", {{max(.x)}}, "\n") )



# pmap --------------------------------------------------------------------

# using pmap with tibble

params <- tibble::tribble(
    ~n, ~min, ~max,
    1L,   0,    1,
    2L,   10,    100,
    3L,   100,    1000
    
)

set.seed(123)

# with function
pmap(params, function(n, min, max) {
    runif(n = n, min = min, max = max)
    })

# Short hand
pmap(params, runif)


modify(head(mtcars), 2) # 
modify(head(mtcars), function(x) x[2])
head(mtcars)[2,]

list(head(mtcars))


# Reduce ------------------------------------------------------------------

# reduce: vector of n, and produce vector of length 1

# reduce(1:3, f) = f(f(1,2),3)

reduce(1:3, sum )
reduce(1:3, `+`)
sum(c(sum(c(1,2)),3) )

reduce(c(0.5, 1:3), sum , .init = 0.5)

library(rlang)

reduce(1:3, ~.x+ .y)
reduce(1:3, function(x,y) x + y)

# Direction
reduce( 1:3, ~.x^2+.y)
sum(sum(c(1^2,2))^2,3)

# Example 3
lim <- function(x,ord){ paste0(x, "+", ord) }
navn <- c("Eirik", "Trym", "Ove")
reduce( navn, lim)
paste( paste0("Eirik","+", "Trym"), "+", "ove")

# Example 4
l <- map(1:3, ~sample(1:10, replace = T))

out <- l[[1]]

intersect(c(1:3), 2)

l[[1]]
l[[2]]
intersect(out, l[[2]])

vec_intersct <- (l[[1]] %in% l[[2]])
unique(l[[1]][vec_intersct])

intersect(out, l[[2]])

# appear in all vectors
reduce(l, intersect)

# Appear in at least one entry
reduce(l, union)

## Accumulate: Return all the intermediate results

accumulate(l, intersect)


l[[1]] # 1
l[[1]][l[[1]] %in% l[[2]]] |> unique() # 2
# OSV
accumulate(l, intersect)

## Reduce
x[[1]] + x[[2]] + x[[3]]

x <- c(4,3,10)

x[[1]] + x[[2]] + x[[3]] # 4+3+10

reduce(x, sum)
accumulate(x, sum)
x[[1]]
x[[1]] + x[[2]]
x[[1]] + x[[2]] + x[[3]]

reduce(x, sum, .init = 0)
reduce(x, sum, .init = 10) # reuce + .init = 10
# Can  be used to make reduce able to check what to return
reduce("a", sum)
reduce("a", sum, .init = 0)







































































