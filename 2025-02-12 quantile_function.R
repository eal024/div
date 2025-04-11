
# Explanation and extracting the percentile.

library(tidyverse)

vec <- sample( x = c(1:200), size = 10000, replace = T)


quantile( vec, prob = c(0.25, 0.5, .75))

qq <- quantile( vec, prob = seq(from = 0.01, to = 1, by = .01) )

dat <- tibble( 
    name = names(qq),
    value = c(qq)
    )

# Legger til variabel
perc <- cut( 
    vec,
    breaks = c(0, unique(dat$value)),
    include.lowest = TRUE
    )

head(perc)

# Observations with percentile
df <- 
    tibble( benefit = vec) |> 
        mutate(
            perc = perc
        )


# 
df1 <- df |>
    arrange( perc, benefit) |> 
    mutate(
        n = 1:n(), .by = perc
    ) |>
    group_by( perc) |>  
    filter( n == max(n) ) |> 
    ungroup() |> 
    mutate(
        cs = cumsum(n),
        andel = cs/sum(n)
    )


View(df1)




df |> 
    group_by(percentil) |> 
    add_count()


vec <- sample( x = c(1:100), size = 10000, replace = T)

cut( vec,  breaks = 100)

dat <- tibble( 
    x = vec, 
    breaks = cut(vec, breaks = 100)
)


dat2 <- dat |> 
    group_by(breaks) |> 
    count() |> 
    ungroup() |> 
    arrange(
        breaks
    ) |> 
    mutate(
        cs = cumsum(n)/sum(n)
    )


dat2 |> writexl::write_xlsx("data_export/data.xlsx")
