

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









