
library(data.table)

dt_navn <- data.table( navn = c("Eirik", "Trond", "Chris"), tall = rnorm(n = 3*100, mean = 10, sd = 2))

# .SD-------------------------------------------------------------

dt <- as.data.table(mtcars)

cols <- names(dt)[grepl( pattern = "^d|p$|c$", x =  names(dt))]

dt[ , lapply(.SD, function(x) mean(x) ), by = .(am), .SDcols = cols] 
dt[ , lapply(.SD, function(x) mean(x) ), by = .(am), .SDcols = -cols]


## All coumlns
dt[ , lapply(.SD, function(x) mean(x))]
dt[ , lapply(.SD, function(x) mean(x)), by = .(am)]



# Reserved commands -------------------------------------------------------

dt_navn[ , .(antall = .N), ]
dt_navn[ , .(antall = .N), by = navn]
dt_navn[ , .(group = .GRP, antall = .N), ]
dt_navn[ , .(group = .GRP, antall = .N), by = navn]
dt_navn[ , .(antall = .GRP), by = navn]


# several steps--------------------------------------------------------------------

dt1 <- dt[ , en := mpg + hp][, to := en + 100][]

dt[ , ':=' (en = NULL, to = NULL) ]

dt[ , ':=' {en = mpg + hp;to = en + 100},]




# -------------------------------------------------------------------------

list(4,2,1,6) |> unlist() |> sort() |> as.list()

dt[ , gearL := list( list(unique(gear))   ),  by = cyl][]

dt[ , arranged := lapply(gearL, function(x) sort(x) ) ][]

dt[ , secondOfList := lapply(gearL, function(x) sort(x)[2] ) ][]

dt[ , ':=' (firstOfList, arranged, secondOfList)]


# benchmark ---------------------------------------------------------------

dt <- CJ( fk = 1:10, dato = seq.Date(from = as.Date("2020-01-01"), to = as.Date("2020-10-01"), by = "months") )


microbenchmark::microbenchmark(
 en =     dt[ , faktor := as.numeric(as.factor(dato)) ] ,
 to =     dt$tillegg <- seq(from =1, to =10, by = 1) |> rep(10)
)



