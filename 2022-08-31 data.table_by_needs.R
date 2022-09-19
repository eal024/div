
library(data.table)

# Struktur

chr_mnd <- ifelse(1:12 < 10, paste0("0", 1:9), 10:12)

tibble(periode = paste0(2010:2012)) |> 
    expand_grid( mnd = ifelse(1:12 < 10, paste0("0", 1:9), 10:12) )

#
dt <- data.table( navn   = c("eva"," jens"),
                  verdi1 = c(1,2),
                  verdi2 = c(4,5))


melt(dt, id.vars = c("navn"), measure.vars = c("verdi1","verdi2"))[order(navn)]
