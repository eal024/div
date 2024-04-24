
# From: https://stata2r.github.io/data.table/#modify

library(data.table)

#

dat <- fread('https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv')

dat |> head()

# index creating
head(dat)[ , index := .I][]

# No need to arrange by origin and then count
head(dat)[ , index_carrier := rowid(origin)][]
head(dat)[ , rows_per_origin := 1:.N, by = origin][]

# count
head(dat)[ , rows_per_origin := .N, by = origin][]

# .GRP = index for each group
head(dat)[ , rows_per_origin := .GRP, by = origin][]



# Importing many files ----------------------------------------------------

# lapply(1:10, function(x) fwrite(mtcars, paste0("temp/",x,".csv") ) )

# fast reading data
files <- dir("temp", pattern = ".csv", full.names = T)

# read
dat <- rbindlist( lapply(files, fread))

dat

## Create data: generate random numbers
d <- data.table( x = 1:10, y = rnorm(10), z = runif(10))


## combination
CJ( id = 1:2, yr = 2001:2003)
tidyr::expand_grid(id = 1:2, yr = 2001:2003)

# alternatives
microbenchmark::microbenchmark(
    tidyr = tidyr::expand_grid(id = 1:2, yr = 2001:2030),
    data.table = CJ( id = 1:2, yr = 2001:2030)
)

# Datetime

# time now, and +1 to 10 secounds.
Sys.time() +  0:10

ad <- Sys.time() +  0:10

IDateTime(ad)

# Sorting
setorder(dat, hp)

# Set names
dt <- CJ( id = 1:2, yr = 2001:2003, type = c("A", "B"))
dt2 <- data.table( en = 1:10, to = 2:11, tre = 3:12, fire = letters[2:11], fem = paste0(1:10,"-",LETTERS[1:10] ))

setnames(dt, gsub("id", "indent_", names(dt)))
dt


dt2[ fem %like% "D|H"] # Regex
dt2[ fem %chin% c("1-A","3-C", "4-D")]

dt2[ , .SD, .SDcols = patterns("o|ire|fe")]

#
dt2[ , .SD, .SDcols = !is.numeric]
dt2[ , .SD, .SDcols = is.numeric]

# Duplication
unique( rbind(dt2,dt2) )

# 
dt3 <- data.table( navn = c("Eirik", "Trond", "Chris", NA_character_, "ove", NA_character_) |> rep(2),
                   alder = c(38,42, 31, NA_integer_, NA_integer_, 40) |> rep(2)
)

na.omit(dt3)

na.omit( dt3, cols = c("navn"))
na.omit( dt3, cols = c("alder"))

# Letters
dt2[ , letters_from_five := grepl("A", fem)][]
dt2[ grepl("A", fem), ,][]
dt2[ , letters_from_five := substring(fem, 3,4)][]
dt2[ , letters_from_five := substring(fem, 1,2)][]



# Modifying advance -------------------------------------------------------

dt2[ , ':='(en_to = en+to),][]

# data.table::update.dev.pkg()
dt2[ , let(to_tre = to + tre),][]

dt2[ , c("ny_1", "ny_2") := .(en+1, to +2),][]

# 
dt2[, -c("letters_from_five", "en_to", "to_tre", "ny_1", "ny_2"), ][]

dt2

# Modify in place
dt2[, c("letters_from_five", "en_to", "to_tre", "ny_1", "ny_2") := .(NULL), ][]

dt2


# Symbols -----------------------------------------------------------------

dt4 <- na.omit(dt3) 


dt4[order(navn)][ , index := .I][] # index obs
dt4[order(navn)][ , index := .N, by = navn][] # index obs for each
dt4[order(navn)][ , index := 1:.N, by = navn][] # count for each
dt4[order(navn)][ , index := .GRP][] # 
dt4[][ , index := .GRP, by = navn][order(index)] # id. each individual 


x <- c(1,2,3,4,5)

x-mean(x)

dmcols <- c("alder")
dt4[ , gr := "lam", ]
dt4[ , paste0(dmcols, "_dm") := lapply(.SD, \(x) x-mean(x)), .SDcols = dmcols, by = gr]

dt4


# More examples -----------------------------------------------------------

# The flights data set
dt_flights <- data.table::fread('https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv')
dt_flights[1:4, 1:8]

# Count flights by origin and month
dt_flights1 <- dt_flights[ , .N , by = .(origin, month)][ order(origin, month)] 

# Growht by months
dt_flights1[][ , growth := N/shift(N,1), by = origin][] |> head(20)
7220/8197
9478/7220

# Relative to one growth
dt_flights1[][ , Test := N[1], by = origin][] |> head(20)
dt_flights1[][ , growth := N/N[1], by = origin][] |> head(20)


# relative to five N[5] osv.

dt <- data.table( y = 2021, mnd = 1:12, day = sample((1:30), size = 12) )

dt[ , date := as.IDate( paste(y , mnd ,day, sep  = "-") ),][]

dt[ , year := data.table::year(date),][]
dt[ , year := date+7,][]

dt[ day == 8, ny:= "en",][]



# Rowwise calc ------------------------------------------------------------

dt <- head(dt_flights)
dt2 <- data.table( a = letters[1:4], b = 1:4, c = 11:14, d = rnorm(4, 0, 1))

dt2

dt2[ , tot_num := rowSums(.SD), .SDcols = patterns("[b-d]")][]

dt2[ , test := fcoalesce(.SD), .SDcols = patterns("d|tot")][]

x = c(9L, NA, 13L, NA, 15L, NA)
y = c(NA, 12L, 5L, NA, NA, NA)
z = c(12L, NA, 1L, 14L, NA, NA)
fcoalesce(list(x,y,z))

dt3 <- data.table( x = c(1,NA,NA), y = c(NA,2,NA), z = c(NA,NA,3))

dt3[ , f := fcoalesce(.SD) , .SDcols = patterns("x|y|z")][]



# Time Series/Panel data --------------------------------------------------

dat <- CJ(id = 1:3, yr = 2001:2004)[ , x := runif(12)]

# Lag/laed
dat[ , xlag := shift(x,1)][]

# by id
dat[ , xlag := shift(x,1), by = id][]

# lead
dat[ , xlag := shift(x,-1), by = id][]

## Replacing var back and forrward

dat[ , c("xlag") := NULL][ yr %in% c(2001,2003), x := NA][]

# replacing with values 
setorder(dat, id, yr) # order
dat[, x:= nafill(x, type = "locf"), by = "id"][] # forward the leasst known obs
dat[, x:= nafill(x, type = "nocb"), by = "id"][] # back the next known obs



# Collapsing --------------------------------------------------------------

dat2 <- dat[ id %in% 1:2, ]

dt2[ ,1:3][ , lapply(.SD, mean), .SDcols = patterns("[b-c]")][]

test <- lapply(1:4, function(x) dt2[,1:3] ) |> dplyr::bind_rows() 

#
test[ , lapply(.SD, mean), .SDcols = is.numeric, by = a ][]

test[ , lapply(.SD, sum), .SDcols = is.numeric, by = a ][]


## Fast collapsing
options(datatable.print.class = T, datatable.print.keys = T)

dt_flights

setkey(dt_flights, month, origin)
dt_flights
setkey(dt_flights, NULL)
dt_flights
setkey(dt_flights, month, origin)

# 

dt_flights[ ,.(beta = coef(lm(arr_delay  ~ dep_delay, .SD) )["dep_delay"]), by = month ]

dt_flights[ ,.(beta = coef(lm(arr_delay  ~ dep_delay, .SD) )["(Intercept)"]), by = month ]

lm( data = dt_flights[ month == 1, ,],
    arr_delay ~ dep_delay)

# Alternativ
mods <- dt_flights[ ,
                    .(mod = list((lm(arr_delay  ~ dep_delay, .SD) ))
                    ),
                    by = month ]


modelsummary::msummary( mods$mod  )
modelsummary::msummary( mods$mod  , coef_omit = "Inter")



# Reshape -----------------------------------------------------------------

dt_id <- dt[ , id := .I][]

# longer
dt_id|> melt(data = _, measure = patterns("_delay"), variable = "d_type")
a <- dt_id|> melt(data = _, measure = patterns("_delay"), variable = "d_type")
a

# wider()
a |> dcast(data = _, id~d_type)

# More complex -- collapsing, stat for several variables
dcast(data = dt_id, origin ~., fun = list(min,mean,max), value.var = c("dep_delay", "arr_delay") )

dt_id[ ,.(dep_delay_mean=  mean(dep_delay)), by = origin][]




# Merging -----------------------------------------------------------------

dt_new <- fread("https://vincentarelbundock.github.io/Rdatasets/csv/nycflights13/airports.csv") 

dt_new[ ,dest := faa]

# Inner merge
merge( x = dt_flights, y = dt_new, by = c("dest")) |> tibble::as_tibble()
dt_flights |> dplyr::inner_join(dt_new) |> tibble::as_tibble()

# Full
merge( x = dt_flights, y = dt_new, by = c("dest"), all = T) |> tibble::as_tibble()

# Left
merge( x = dt_flights, y = dt_new, by = c("dest"), all.x = T) |> tibble::as_tibble()

# Right
merge( x = dt_flights, y = dt_new, by = c("dest"), all.y = T) |> tibble::as_tibble()


# Keep non maching rows: ANTI

dt_flights[ !dt_new ,  on = c('dest' )] |> nrow()
dt_flights[ dt_new ,  on = c('dest' )] |> nrow()
merge( x = dt_flights, y = dt_new, by = c("dest"), all.y = T) |> nrow()
merge( x = dt_flights, y = dt_new, by = c("dest"), all.x = T) |> nrow()

#left (dt_flight)
dt_new[ dt_flights ,  on = c('dest' )] |> nrow()
merge( x = dt_flights, y = dt_new, by = c("dest"), all.x = T) |> nrow()
dplyr::left_join(x = dt_flights, y = dt_new, by = "dest") |> nrow()

# Fast merging with data.table


setkey(dt_flights, dest)

dt_b_f <- data.table::copy(dt_flights) 
dt_b_new <- data.table::copy(dt_new)

dt_b_f |> setkey( NULL)

# How much time do we save? -- to small to do a good comparison
microbenchmark::microbenchmark(
    no_key = merge(dt_flights, dt_new),
    key = merge(dt_b_f, dt_new)
) 



