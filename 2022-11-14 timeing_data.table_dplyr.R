
rm(list = ls(all = T))

fun_rep <- function( n ) {
    x <- c("01", "02", "03", "04", "05")
    sample( x, size =n, replace = T)
}

n <- 1000000
dt <- data.table( dato = paste0("2020",rep(11,times = n),fun_rep(n) )  )
dt <- dt[ , dato_num := as.numeric(dato),][]


head(dt)

dt[ , test1 := ymd(dato) , ][] 
dt[ , test1 := anytime::anydate(dato) , ][] 

date_from_string <- function( string ){
    data.table::as.IDate( paste0( substring(string, 1,4),"-",substring(string, 5,6),"-",substring(string, 7,8) ) )   
}

string <- c("202001")
date_from_string( string, truncate = 1) |> str()

microbenchmark::microbenchmark(
    lubridata = dt[ , test1 := ymd(dato) , ][] ,
    anytime = dt[ , test1 := anytime::anydate(dato) , ][] ,
    fasttime =  parse_date_time(dt$dato, "ymd") |> as.data.table()
)


