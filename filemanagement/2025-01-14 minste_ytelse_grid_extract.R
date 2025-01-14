

library(tidyverse)

tbl <- expand_grid(
    barn = 0:14,
    minsteytelse = c(2.28, 2.48, 2.481, 2.66, 2.33, 2.91)
    )  |> 
    arrange(
        minsteytelse
    )


tbl1 <- tbl |>
    mutate(
        gift_samboer = ifelse( minsteytelse %in% c(2.28, 2.33, 2.66), 1, 0),
        ung_ufor     = ifelse( minsteytelse %in% c(2.66, 2.91), 1, 0),
        konvertert   = ifelse( minsteytelse %in% c(2.33, 2.481 ), 1, 0),
        minsteytelse = ifelse( minsteytelse == 2.481, 2.48, minsteytelse) 
    )


# Hypotetisk ny minsteytelse
tbl2 <- tbl1 |>
    mutate(
        hyp_minsteytelse = barn*0.2 + minsteytelse
    )
