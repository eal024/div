# Simulere data
n <- 100
beta <- 0.9
cons <- 0

y <- rep(0,n)
e <- rnorm(n, 0, sd = 0.2)
y[1] <- 0

for(i in 2:n){ 
    y[i] <- cons + beta*y[i-1] + i*0.01 + e[i]}

model <- lm( data = data.frame(y = y, t = 1:100), formula =  y ~ t )
summary(  model)
