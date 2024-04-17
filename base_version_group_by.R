




df <- data.frame( a = 1:10, b = letters[1:10], team = rep( c("1", "2"), 5) ) 

# Group by
aggregate( df$a, list(df$b, df$team), \(x) median(x) )


