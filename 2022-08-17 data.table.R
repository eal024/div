

Sys.setlocale("LC_CTYPE")
library(data.table)

# Go trough data.table, based on:
# http://brooksandrew.github.io/simpleblog/articles/advanced-data-table/
#


# 1. columns of lists -----------------------------------------------------

dt <- as.data.table(mtcars) |> head() 

dt[, .(cyl, gear),]

dt[, unique(gear), by = cyl]

# Adding each unique to line
dt[, .(cyl, gear),][ , gearL := .(list(unique(gear))), by = cyl][]


## Get second element from each list in gearL1
dt1 <- dt[, .(cyl, gear),][ , gearL := .(list(unique(gear))), by = cyl][]

dt1[ , ':=' (gear1 = lapply(gearL, function(x) x[1]),
             gear2 = lapply(gearL, function(x) x[2])
             ) ,][]

# Denne fungerer ogs??
dt1[ ,tt := lapply(gearL,`[` ,2 ), ][]


# 2. temporary variables  -------------------------------------------------

dt[ , .(sum_cyl = sum(cyl)), by = am ]

# Permanent change to a variable
dt[,cyl := 100*cyl,][ , .(sum_cyl = sum(cyl)), by = am ]

# Giving variables names with list
dt[ , {en = cyl*100;sum_cyl = sum(cyl);list( sum_cyl = sum_cyl) }, by = am]



# 3. shift and lead -------------------------------------------------------

# Shift
dt[1:10, ][ ,cyl_shift := shift(cyl, 1, type = "lead"),][]
dt[1:10, ][ ,cyl_shift := shift(cyl, 2, type = "lead"),][]

# by
dt[1:10, ][order(gear,cyl)][ ,cyl_shift := (shift(cyl, 1, type = "lead")), by = gear][]

# lead
dt[1:10, ][order(gear,cyl)][ ,cyl_shift := shift(cyl, 1, type = "lead"), by = gear][]

# Lag
dt[1:10, ][order(gear,cyl)][ ,cyl_shift := shift(cyl, 1, type = "lag"), by = gear][]



# 4. BY  ------------------------------------------------------------------

# The mean of all other than gear == 4 by cyl:

dt[ gear != 4 & cyl == 6, .(m = mean(mpg)),]

# For all combination of gear and cyl

dt[, dt[!gear %in% unique(dt$gear)[.GRP], mean(mpg), by = cyl], by = gear]

# Alternativ
dt[, dt[!gear %in% .BY[[1]], mean(mpg), by = cyl], by = gear]


dt
# GRP: Special symbols -- grp eq. group-counter.
dt[, .GRP, by = cyl][]

dt[ , gr_id := .GRP, by = cyl][order(gr_id)]



# 5. .SD ---------------------------------------------------------------------

# .SD = a data.table -> containing the subset of X`s data for each group. Excluding group used in by

dt[ , .SD[, mean(mpg)], by = gear]

dt[ gear == 4, .(mean = mean(mpg)), ]



# 6. Nested data ----------------------------------------------------------

data <- data.table( 
    set = c(1,2),
    data = list(dt,dt)
    )

# Nest by group 
dt[, list(dt = list(.SD)), by = gear][]

dt_nested_gear <- dt[, list(dt = list(.SD)), by = gear][]


dt_nested_gear[ , ny := lapply(dt,  function(x) x[,.(mean_mpg = mean(mpg)),] ),
                ][ , ]


data.table( gear = 4, dt_nested_gear$ny[[1]])

unnest(dt_nested_gear,ny)

tidyr::unnest(dt_nested_gear,ny)



# 7. Examples -------------------------------------------------------------

# Return vector
dt[ , cyl]

# Return data.table
dt[ , .(cyl)]

# Column based on position
dt[ , 2, ]

# or multiple columns
dt[ , c(2,4), ]

dt[ , !c(2,4), ]

# Keeping by using regex
dt[ , names(dt) %like%  "ar", with =F ]
dt[ , grepl( "ar", names(dt)), with =F ]

# Renames
dt[ ,c(1,2), ] |> setnames(x = _,  c("mpg", "cyl"), c("en", "to")) |> print()



# Binary fast manipulation ------------------------------------------------

# 1. Search: Find values from sorted list

x <- c(5,10,7,20,3,13,26)

# Finding 20 = y
y <- 20
# 1. sort
x <- sort(x)

# 2. middle values, are y
y > median(x)

if(y > median(x)){
    x[(as.integer(length(x)/2)+1):length(x)]
    }else if(y < median(x)){
        x[1:as.integer(length(x)/2)]
    }else{
        return(median(x))
        }

# Setting key, telles which variable the data is sorted by


dt2 <- as.data.table(mtcars)


setkey(dt2,disp)

microbenchmark::microbenchmark(
    en = dt2[ disp %in% c(100:200),, ],
    to = as.data.table(mtcars)[ disp %in% c(100:200),, ]
    )

# ID key var.
key(dt2)


# order -------------------------------------------------------------------

setorder(dt, hp);dt
setorder(dt, -hp) |> print()

# in flow
dt[ order(-mpg)]




# summarise ---------------------------------------------------------------

dt[ ,.( snitt_mpg = mean(mpg),
        dv_mgp = sd(mpg),
        min_mpg = min(mpg)
        )][]


# SD
dt[ ,lapply(.SD, function(x) mean(x)), .SDcols = c("mpg", "cyl")][]

# SD defualt = all continous var
dt[ , lapply(.SD, function(x) mean(x) ),]



# Keyby is faster.
microbenchmark::microbenchmark(
    by = as.data.table(mtcars)[ , lapply(.SD, function(x) mean(x) ), by = am],
    keyby = as.data.table(mtcars)[ , lapply(.SD, function(x) mean(x) ), keyby = am]
    )


dt[order(am)][ , id := 1:.N,][]


dt2 <- rbind( dt, dt)

#
setkey(dt2,id)
unique(dt2)


# Values from  a groupe
dt[order(-am)][]
dt[ ,.SD[1:2], by = am]

# last value from a group (see the ID)
dt <- dt[order(id)]
dt[ , .SD[.N], by = am][]



































