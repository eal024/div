
Sys.setlocale("LC_CTYPE")
library(tidyverse)
#

# Uttrekket: Data fra SSB -- innvadrerbefolkning
dat <- readxl::read_excel("data/befolkningsframskrivninger.xlsx", skip = 3)

# ordner litt p?? navn
dat1 <- dat |> 
    rename( kjonn  = 1, alder = 2, type = 3, alternativ = 4) |> 
    fill(  kjonn, alder,  .direction = "down" )

# Velger de aktuelle typene 
dat2 <- dat1 |> 
    filter( type %in% c("Innvandrere fra Vest-Europa, USA, Canada, Australia og New Zealand",
                        "Innvandrere fra ??steuropeiske EU-land",
                        "Innvandrere fra Asia, Afrika, Latin-Amerika og ??st-Europa utenfor EU"
                        )
            ) |> 
    pivot_longer( -c(kjonn:alternativ), "ar", "value") |> 
    group_by(type,ar) |> 
    summarise( antall = sum(value)) |> 
    pivot_wider( names_from = ar, values_from = antall)


# skriver ut
dat2 |> writexl::write_xlsx("data_export/2023-01-12 befolkningsfram.xlsx")