

# Based on blog-post: https://www.r-bloggers.com/2025/01/some-of-the-more-useful-tidyverse-functions/

library(tidyverse)
df <- as_tibble(mtcars)
df$brand <- word( rownames(mtcars), 1) 


# Longer
df_long <- df |> pivot_longer( cols = !brand, names_to = "xvar", values_to = "value")

# Wider: Keep mean for all brands
df_wider <- df_long |> pivot_wider( names_from = brand, values_from = value, values_fn = function(x) mean(x, na.rm = T) )


df_is_num <- select(df_wider, where( is.numeric) )

# Rowmean
df_wider |>  mutate(
    row_mean = rowMeans( across(where(is.numeric)), na.rm = TRUE)
    row_sd = pmap_dbl(df_is_num, \(x) sd(x, na.rm = T) )
    )


apply( df_is_num, 1, sd, na.rm = TRUE) 
t(df_is_num) |> as.data.frame() |> map( \(x) sd(x, na.rm= T))
# 1 is margin = 1, rowwise vs. 2 = colwise
apply( df_is_num, 1, sd, na.rm = TRUE) 


# Cross tab/ margins and total percentage
count_cyl_gear <- mtcars |> count( cyl, gear)

count_cyl_gear_all <- count_cyl_gear |>
    # count 0-s for all values for cyl and gear -- combination
    complete( cyl = unique(mtcars$cyl), gear = unique(mtcars$gear), fill = list( n = 0)  )

# wide freq.
count_cyl_wider <- count_cyl_gear_all |> pivot_wider( names_from = gear, values_from = n)


tabel <- count_cyl_wider |> 
    mutate(
        cyl = as.character(cyl),
        rowTotal = rowSums(count_cyl_wider |> select(-cyl) ),
        percent = rowTotal/sum(rowTotal)
    )  
 
 # Adding col-totalt
tabel_total <- tabel |> 
    summarise(
        cyl = "Totalt",
        across( -c(cyl), sum, na.rm = T )
    )

# Final tabel
tabel |> 
    bind_rows(
        tabel_total
    )