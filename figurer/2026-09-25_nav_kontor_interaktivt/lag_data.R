# lag_data.R
# Eksporterer helper::nav_kontor til nav_kontor.json for det interaktive
# Leaflet-kartet i index.qmd. Kjør fra denne mappa: Rscript lag_data.R

library(dplyr)

df_kontor <- helper::nav_kontor |>
    as_tibble() |>
    transmute(navn, gate, postnr, poststed, kommune,
              ansatte = antall_ansatte, dropin, lat = round(lat, 5), lon = round(lon, 5)) |>
    arrange(desc(coalesce(ansatte, 0L)))

jsonlite::write_json(df_kontor, "nav_kontor.json", na = "null", digits = NA, pretty = FALSE)
cat("Skrevet nav_kontor.json:", nrow(df_kontor), "kontor\n")
