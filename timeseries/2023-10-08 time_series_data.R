

# Temporal data classes

# integer: number of dagys since jan. 1970
as.Date(0)
lubridate::as_date(0)

# Calcuating with times
start <- as.Date(100)
end  <- as.Date(200)


# Calcualte
end - start


# POSIXct
streng <- "2023-10-09 20:00 UTC"

start_work <- as.POSIXct(streng)
end_work <- as.POSIXct("2023-11-09 15:00 UTC")


end_work - start_work

# ISO 8601: Y->mnd->day
# Formating
lubridate::parse_date_time( "April 22, 2022", orders = "%B %d, %Y")
?strptime

d <- c("12/20/2022", "2020-12-21")

parse_date_time(d, orders = c("%m/%d/%Y",
                              "%Y-%m-%d"
                              ))



## Time series attributes
# attributes

# Overlapping issues

# attributes
ts_x <- ts( data = rnorm(n = 12*(6), mean = 10, sd = 2) |> round(2),
            start = c(2018,1),
            end = c(2023,12),
            frequency = 12)

# example 2
ts_quarter <- ts( data = rnorm(n = 100, 10, 1),
                  start = c(1970,1)
                  )
# get attributs
start(ts_x)
end(ts_x) |> lubridate::date_decimal()

# 
end(ts_quarter) |> lubridate::date_decimal()
frequency(ts_x)


# The zoo pacakges --------------------------------------------------------

library(zoo)
library(tidyverse)

xts <- as.zoo(ts_x)

# ggplot
ggplot( data = xts, aes(x = Index, y = xts) ) + geom_line()



# zoo ---------------------------------------------------------------------

xts
ts_x2 <- ts( data = rnorm(n = 12*(6), mean = 10, sd = 2) |> round(2),
            start = c(2019,1),
            end = c(2024,12),
            frequency = 12) |> 
    as.zoo()

coredata(xts)
index(xts)

# Overlapping 
index(xts) %in% index(ts_x2)

subset <- !index(xts) %in% index(ts_x2)


## zoo and data.frame
df <- data.frame( date = seq.Date(from = ymd("2010-01-01"), length.out = 24, by = "month"),
            value = runif(min = 0, max = 1000, n = 24)
            )

# as.zoo
df |> as.zoo() 
df_zoo <- zoo( df$value, order.by = df$date) 
zoo::fortify.zoo(df_zoo)



# Subsetting a window -----------------------------------------------------

library(quantmod)

xts <- ts( c(1:100), start = c(2000,1), frequency = 12)

window(xts, end = c(2006,1))
window(xts, start = c(2006,2))

zxts <- zoo::as.zoo(xts)

# Subset
subset <- index(zxts) >= "2006-01-01" & index(zxts) <= "2007-01-01"

zxts[subset]
zxts[!subset]


quantmod::getSymbols( "^DJI")
subset <- index(DJI) >= "2018-01-01" & index(DJI) <= "2020-01-01"

DJI[subset] |> autoplot()















