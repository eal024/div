
# Utregning av minstesatser over ??ret
g <- helper::grunnbelop_long

# Beholder G to ganger i ??ret
g1 <- g |>
    mutate( ar = year(dato)) |> 
    select(ar, g = grunnbelop_per_ar) |> 
    distinct() |> 
    filter( ar %in% c(2015:2023))


g2 <- g1 |> 
    mutate( deler = rep( c(4/12, 8/12), times = nrow(g1)/2 ),
            `ugradert minstesats` = g*deler*2.48,
            `ugradert minstesats ung ufor` = g*deler*2.91,
            EU60 = g*deler*2.971
            ) |>
    group_by(ar) |> 
    summarise(
        EU60 = sum(EU60),
        ordinar = sum(`ugradert minstesats`),
        ung_ufor = sum(`ugradert minstesats ung ufor`)
    ) 



g2 |> writexl::write_xlsx("data_export/2024-10-18 EU60_og_minstesatser.xlsx")
