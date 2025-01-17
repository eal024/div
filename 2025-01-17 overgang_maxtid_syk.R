
library(tidyverse)


df <- readxl::read_excel("data/2025-01-17 overgang_fra_maxtid_syk.xlsx", skip = 3) |> 
    janitor::clean_names()

names(df)

new_names <- c("periode", "ant_oppbrukt_syk", "iarbeid", "percent", "arbeid_og_ytelse", "prosent_i_arbeid","arbeid_ufor","arbeid_aap", "ufor" ,"aap","pensjon", "dagp", "dod", "annet") 

names(df)  <- new_names

# Clean
df1 <- df  |>
    filter( ! is.na(periode) & ! is.na(ant_oppbrukt_syk) & str_detect(periode, "[0-9]"))  |> 
    mutate(
        periode = ym(periode),
        across(
            .cols = ant_oppbrukt_syk:annet, .fns = \(x) as.numeric(x)
        )
    )

# Stat
df2 <- df1 |> 
    filter( year(periode) == 2019) |> 
    select( periode, ufor)


df1 |>
    group_by(year(periode)) |> 
    summarise( ufor = mean(ufor) )
