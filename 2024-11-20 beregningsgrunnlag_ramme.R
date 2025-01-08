
# Pakker
library(tidyverse)

# Data
df <- data.frame( fk = c(1:5)) |>  
    transform( ufor = sample( size = 5, x = c(2000:2020), replace = T)
               )


fn_perioder <- function(x){ seq( from = x-5,  length.out = 5 )}

df$for_ufor <- lapply(df$ufor, function(x) fn_perioder(x))

# Unnested data
df1 <- df |> unnest( cols = for_ufor)


# Inntekt sample
df1$inntekt <- sample( size = nrow(df1), x = seq(0,10, by = 0.1), replace = T )

# Arrange
df2 <- df1 |> arrange( fk, desc(inntekt) )

# Give index
df3 <- df2 |>  mutate( index = 1:n(), .by = fk )


# Beholder 1:3 inntekts??r
df3 |> filter( index %in% 1:3) 
    

# Uf??retrygd
df3 |> 
    mutate( inntekt_bg = ifelse(inntekt > 6, 6, inntekt), .by = fk) |> 
    summarise( 
        uft = mean(inntekt_bg), .by = fk
        )
