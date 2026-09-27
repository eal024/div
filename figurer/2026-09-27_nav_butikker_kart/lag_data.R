# lag_data.R
# Kommunetall for kartet: butikker per kommune, Nav-mottak per kommune, og
# avstand fra hver butikk til nærmeste Nav-mottak (storsirkel). Leser de
# kommunekoblede filene fra koble_kommune.py og skriver JSON til data/web/.
# Kjør fra denne mappa: Rscript lag_data.R

suppressMessages({ library(tidyverse); library(jsonlite) })

fn_les_punkter <- function(fil) {
    g <- fromJSON(fil, simplifyVector = FALSE)$features
    map_dfr(g, \(f) as_tibble(map(f$properties, \(v) if (is.null(v)) NA else v)) |>
                mutate(lon = f$geometry$coordinates[[1]], lat = f$geometry$coordinates[[2]]))
}

df_butikk <- fn_les_punkter("data/butikker_koblet.geojson") |>
    mutate(knr = coalesce(geo_knr, kommunenr), kommune_navn = coalesce(geo_kommune, str_to_title(kommune))) |>
    filter(knr != "2100")                                  # Svalbard er ikke blant de 357 kommunene
df_kontor <- fromJSON("data/kontor_raa.json") |> as_tibble()
# Bare mottak som hører til lokalkontor (hjelpemiddelsentralene 47xx har også mottak)
df_mottak <- fn_les_punkter("data/mottak_koblet.geojson") |>
    filter(enhet_nr %in% df_kontor$enhet_nr) |>
    mutate(knr = geo_knr, kommune_navn = geo_kommune)
df_kommuner <- fromJSON("data/kommuner.json") |> as_tibble() |>
    transmute(knr = kommunenummer, kommune_navn = kommunenavn, fnr = str_sub(knr, 1, 2))

# Storsirkelavstand i km
fn_hav <- function(lon1, lat1, lon2, lat2) {
    r <- pi / 180
    a <- sin((lat2 - lat1) * r / 2)^2 + cos(lat1 * r) * cos(lat2 * r) * sin((lon2 - lon1) * r / 2)^2
    2 * 6371 * asin(sqrt(a))
}

# Nav-punkter: mottak pluss kontor uten registrert mottak på samme sted
df_navpkt <- bind_rows(
    df_mottak |> transmute(enhet_nr, lat, lon, kilde = "mottak", sted = stedsbeskrivelse, kommune_navn,
                          n_dager_aapent, n_dager_dropin),
    df_kontor |> transmute(enhet_nr, lat, lon, kilde = "kontor", sted = str_to_title(kommune), kommune_navn = str_to_title(kommune),
                          n_dager_aapent = NA_integer_, n_dager_dropin = NA_integer_)
) |>
    filter(!is.na(lat)) |>
    left_join(df_kontor |> select(enhet_nr, kontor_navn = navn, k_lat = lat, k_lon = lon), by = "enhet_nr") |>
    mutate(avstand_kontor = fn_hav(lon, lat, k_lon, k_lat),
           type = if_else(avstand_kontor < 0.3, "kontor", "mottak"),
           nokkel = paste(enhet_nr, round(lat, 3), round(lon, 3))) |>
    arrange(enhet_nr, kilde) |>                        # kontor-raden vinner bare der mottak mangler
    distinct(nokkel, .keep_all = TRUE) |>
    group_by(enhet_nr) |>
    mutate(type = if_else(type == "kontor" & row_number() == which(type == "kontor")[1], "kontor", type)) |>
    ungroup()

# Nærmeste Nav-punkt for hver butikk (6 147 x ~400, håndterbart som matrise)
m <- outer(seq_len(nrow(df_butikk)), seq_len(nrow(df_navpkt)), \(i, j)
           fn_hav(df_butikk$lon[i], df_butikk$lat[i], df_navpkt$lon[j], df_navpkt$lat[j]))
df_butikk <- df_butikk |>
    mutate(naermeste_mottak = df_navpkt$enhet_nr[apply(m, 1, which.min)],
           avstand_km       = round(apply(m, 1, min), 1))

df_kontor_navn <- df_kontor |> select(enhet_nr, kontor_navn = navn)
df_butikk <- df_butikk |> left_join(df_kontor_navn, by = c("naermeste_mottak" = "enhet_nr"))

# Kommunetall
df_stat <- df_kommuner |>
    left_join(df_butikk |> group_by(knr) |>
                  summarise(n_butikker = sum(!kiosk), n_kiosk = sum(kiosk),
                            avstand_median = round(median(avstand_km[!kiosk]), 1),
                            avstand_maks   = round(max(avstand_km[!kiosk]), 1),
                            naermeste_navn = names(which.max(table(kontor_navn[!kiosk]))), .groups = "drop"),
              by = "knr") |>
    left_join(df_mottak |> filter(!is.na(knr)) |> group_by(knr) |>
                  summarise(n_mottak = n(), n_mottak_dropin = sum(n_dager_dropin > 0, na.rm = TRUE), .groups = "drop"),
              by = "knr") |>
    left_join(df_kontor |> group_by(kommunenr) |> summarise(n_kontor = n(), .groups = "drop"),
              by = c("knr" = "kommunenr")) |>
    mutate(across(c(n_butikker, n_kiosk, n_mottak, n_mottak_dropin, n_kontor), \(v) replace_na(v, 0L)),
           har_mottak = n_mottak > 0,
           status = case_when(n_kontor > 0 ~ "kontor", n_mottak > 0 ~ "mottak", TRUE ~ "ingen"))

# Nærmeste mottak for kommuner uten mottak: minste butikkavstand som proxy
cat("Nav-punkter:", nrow(df_navpkt), "| kontor:", sum(df_navpkt$type == "kontor"), "| mottak:", sum(df_navpkt$type == "mottak"), "\n"); cat("Kommuner:", nrow(df_stat), "| med kontor:", sum(df_stat$n_kontor > 0),
    "| bare mottak:", sum(df_stat$status == "mottak"), "| ingen:", sum(df_stat$status == "ingen"), "\n")
cat("Butikker (ekskl. kiosk):", sum(!df_butikk$kiosk), "| median avstand:", median(df_butikk$avstand_km[!df_butikk$kiosk]),
    "km | andel innen 5 km:", round(100 * mean(df_butikk$avstand_km[!df_butikk$kiosk] <= 5)),
    "% | innen 20 km:", round(100 * mean(df_butikk$avstand_km[!df_butikk$kiosk] <= 20)), "%\n")
cat("Kommuner uten mottak:\n"); print(df_stat |> filter(status == "ingen") |> select(knr, kommune_navn, n_butikker, avstand_median) |> arrange(desc(avstand_median)) |> as.data.frame(), row.names = FALSE)
cat("\nLengst fra Nav (median butikkavstand), topp 10:\n"); print(df_stat |> arrange(desc(avstand_median)) |> select(kommune_navn, status, n_butikker, avstand_median) |> head(10) |> as.data.frame(), row.names = FALSE)

# Skriv
dir.create("data/web", showWarnings = FALSE)
# Kompakt: bare butikker som tegnes (ikke kiosk), fire desimaler, radvis matrise
# med feltnavn i «felt» (Quarto Pub avviser filer over ~1 MB)
df_ut <- df_butikk |> filter(!kiosk) |>
    transmute(lat = round(lat, 4), lon = round(lon, 4), navn, kjede, kommune = kommune_navn,
              avstand_km, naermeste = kontor_navn, ansatte = antall_ansatte)
write_json(list(felt = names(df_ut), rader = pmap(df_ut, list) |> map(unname)),
           "data/web/butikker.json", digits = NA, na = "null", auto_unbox = TRUE)
write_json(df_navpkt |> select(enhet_nr, kontor_navn, type, sted, kommune = kommune_navn, n_dager_aapent, n_dager_dropin, lat, lon),
           "data/web/navpunkter.json", digits = NA, na = "null")
write_json(df_stat, "data/web/kommune_stat.json", digits = NA, na = "null")
write_json(list(butikker = sum(!df_butikk$kiosk), kiosker = sum(df_butikk$kiosk), navpunkter = nrow(df_navpkt), kontor = nrow(df_kontor),
                kommuner = nrow(df_stat), kommuner_uten_mottak = sum(df_stat$status == "ingen"),
                median_km = median(df_butikk$avstand_km[!df_butikk$kiosk]),
                andel_5km = mean(df_butikk$avstand_km[!df_butikk$kiosk] <= 5), andel_20km = mean(df_butikk$avstand_km[!df_butikk$kiosk] <= 20),
                dato = "2026-09-24"), "data/web/metadata.json", auto_unbox = TRUE, digits = NA)
cat("skrevet data/web/\n")
