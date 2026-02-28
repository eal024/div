

expand_grid( ar = 2013:2015, mnd = c( str_c("0",1:9), 10:12) ) |> transmute( periode = str_c(ar,mnd) |> ymd( truncated = 1))



expand_grid( ar = 2013:2015, mnd = c( str_c("0",1:9), 10:12) ) |> transmute( periode = str_c(ar,mnd) |> ymd( truncated = 1))

mnd <- c( str_c("0",1:9), 10:12)
ar  <- rep(seq(from = 2014, to = 2016), each = 12)

ymd(str_c( ar, rep(mnd, times = length(ar))), truncated = 1)

seq.Date( from = ymd(20120101), to = ymd(20200101), by = "months" )


en <- ymd("2022-11-07")
to <- ymd("1984-11-07")

as.integer(" -to)/365.25)
