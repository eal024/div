

#
library(fixest)

names(mtcars)


formula <- reformulate(c("cyl", "wt"), response = "mpg")

feols( data = mtcars, fm = formula)


ls()[ ! ls() %in% c("data")]


rm( list = ls()[ ! ls() %in% c("keep var")] )

