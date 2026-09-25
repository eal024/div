# lag_data.R
# Varig lønnstilskudd (VLT) og personer med nedsatt arbeidsevne per fylke,
# månedlig januar 2024 til august 2026. Leser NAV-filene i data/raw/ og
# skriver JSON til data/web/ som index.qmd leser med Observable Plot.
#
# Kilder (nav.no, åpne data):
#   TILT110 Tiltaksdeltakere på lønnstilskudd. Demografi. Tidsserie måned
#     (ark «Tiltak og fylke», blokkene «I alt varig lønnstilskudd» og
#      «I alt midlertidig lønnstilskudd»). Desember-filene dekker hele året.
#   NED150 Personer med nedsatt arbeidsevne. Fylke og alder. Tidsserie måned
#     (ark «1a. Fylke Antall» og «2a. Fylke Prosent av befolkning»).
# Kjør fra denne mappa: Rscript lag_data.R

suppressMessages({ library(tidyverse); library(readxl); library(jsonlite) })

mnd_navn <- c("januar", "februar", "mars", "april", "mai", "juni", "juli",
              "august", "september", "oktober", "november", "desember")

fn_fylke <- function(x) {
    x |> str_remove("^\\d+\\s+") |> str_remove("\\s+-\\s+.*$") |> str_trim()
}

# 1. TILT110: lønnstilskudd per fylke ---------------------------------------

fn_tilt_blokk <- function(fil, aar, blokk) {
    x <- as.data.frame(suppressMessages(read_excel(fil, sheet = "Tiltak og fylke", col_names = FALSE)))
    i0  <- which(x[[1]] == blokk)
    hdr <- max(which(x[[2]] == "Gjennomsnitt hittil i år" & seq_len(nrow(x)) < i0))
    mnd <- as.character(x[hdr, 3:ncol(x)])
    mnd <- mnd[str_to_lower(mnd) %in% mnd_navn]      # 2026-fila har en kolonne merket «NA»
    i1  <- i0 + 1
    while (i1 <= nrow(x) && !is.na(x[i1, 1])) i1 <- i1 + 1
    x[(i0 + 1):(i1 - 1), c(1, 3:(2 + length(mnd)))] |>
        set_names(c("enhet", mnd)) |>
        pivot_longer(-enhet, names_to = "mnd", values_to = "antall") |>
        mutate(aar     = aar,
               mnd_nr  = match(str_to_lower(mnd), mnd_navn),
               periode = sprintf("%d-%02d-01", aar, mnd_nr),
               antall  = suppressWarnings(as.integer(antall)),
               fylke   = fn_fylke(enhet)) |>
        filter(!fylke %in% c("Svalbard og øvrige områder", "Ukjent")) |>
        select(fylke, periode, antall)
}

tilt_filer <- tribble(
    ~fil,                          ~aar,
    "data/raw/tilt110_202412.xlsx", 2024,
    "data/raw/tilt110_202512.xlsx", 2025,
    "data/raw/tilt110_202608.xlsx", 2026
)

df_vlt <- tilt_filer |>
    pmap_dfr(\(fil, aar) bind_rows(
        fn_tilt_blokk(fil, aar, "I alt varig lønnstilskudd")       |> mutate(tiltak = "Varig lønnstilskudd"),
        fn_tilt_blokk(fil, aar, "I alt midlertidig lønnstilskudd") |> mutate(tiltak = "Midlertidig lønnstilskudd")
    )) |>
    arrange(tiltak, fylke, periode)

# 2. NED150: nedsatt arbeidsevne per fylke ----------------------------------

fn_ned_ark <- function(fil, aar, ark, verdi) {
    x <- as.data.frame(suppressMessages(read_excel(fil, sheet = ark, col_names = FALSE)))
    hdr <- which(x[[3]] == "Januar")[1]
    # 2024- og 2025-filene har en tom kolonne etter januar: velg kolonner etter månedsnavn
    kol <- which(str_to_lower(as.character(x[hdr, ])) %in% mnd_navn)
    mnd <- as.character(x[hdr, kol])
    x[(hdr + 1):nrow(x), c(2, kol)] |>
        set_names(c("enhet", mnd)) |>
        filter(!is.na(enhet), enhet != "I alt") |>
        pivot_longer(-enhet, names_to = "mnd", values_to = "verdi") |>
        mutate(aar     = aar,
               mnd_nr  = match(str_to_lower(mnd), mnd_navn),
               periode = sprintf("%d-%02d-01", aar, mnd_nr),
               verdi   = suppressWarnings(as.numeric(verdi)),
               fylke   = fn_fylke(enhet)) |>
        filter(!fylke %in% c("Svalbard og øvrige områder", "Ukjent")) |>
        select(fylke, periode, {{ verdi }} := verdi)
}

ned_filer <- tribble(
    ~fil,                           ~aar,
    "data/raw/ned150_202412.xlsx",  2024,
    "data/raw/ned150_202512.xlsx",  2025,
    "data/raw/ned150_202608.xlsx",  2026
)

df_nae <- ned_filer |>
    pmap_dfr(\(fil, aar) {
        a <- fn_ned_ark(fil, aar, "1a. Fylke Antall",                antall)
        p <- fn_ned_ark(fil, aar, "2a. Fylke Prosent av befolkning", pst_befolkning)
        left_join(a, p, by = c("fylke", "periode"))
    }) |>
    arrange(fylke, periode)

# 3. Sammenlikning: fylkets andel av landet ---------------------------------

# Andel av nedsatt arbeidsevne (fordelingsnøkkelen) mot andel av VLT-plassene,
# målt i desember 2025, siste måned før budsjettåret 2026.
ref <- "2025-12-01"

df_andel <- df_vlt |>
    filter(tiltak == "Varig lønnstilskudd", periode == ref) |>
    transmute(fylke, vlt = antall) |>
    inner_join(df_nae |> filter(periode == ref) |> select(fylke, nae = antall, pst_befolkning),
               by = "fylke") |>
    mutate(andel_vlt   = vlt / sum(vlt),
           andel_nae   = nae / sum(nae),
           vlt_per_1000_nae = 1000 * vlt / nae,
           ratio       = andel_vlt / andel_nae) |>
    arrange(desc(ratio))

# Grupper til siste figur: fire fylker med høyest og fire med lavest ratio
df_andel <- df_andel |>
    mutate(gruppe = case_when(
        row_number() <= 4                     ~ "Flest VLT per nedsatt arbeidsevne",
        row_number() > n() - 4                ~ "Færrest VLT per nedsatt arbeidsevne",
        TRUE                                  ~ "Midt imellom"
    ))

# Indeksert VLT-serie (desember 2025 = 100) med gruppe
df_indeks <- df_vlt |>
    filter(tiltak == "Varig lønnstilskudd") |>
    group_by(fylke) |>
    mutate(indeks = 100 * antall / antall[periode == ref]) |>
    ungroup() |>
    left_join(df_andel |> select(fylke, gruppe, ratio), by = "fylke")

# 4. Skriv -----------------------------------------------------------------

write_json(df_vlt,    "data/web/lonnstilskudd_fylke.json", digits = NA)
write_json(df_nae,    "data/web/nedsatt_fylke.json",       digits = NA)
write_json(df_andel,  "data/web/andel_fylke.json",         digits = NA)
write_json(df_indeks, "data/web/vlt_indeks.json",          digits = NA)
write_json(list(sist_oppdatert = max(df_vlt$periode), referanse = ref,
                generert = format(Sys.time(), "%Y-%m-%d")),
           "data/web/metadata.json", auto_unbox = TRUE)

cat("VLT:", nrow(df_vlt), "rader |", "NAE:", nrow(df_nae), "rader |",
    "perioder:", n_distinct(df_vlt$periode), "\n")
print(df_andel |> mutate(across(c(andel_vlt, andel_nae), \(v) round(100 * v, 1)),
                         ratio = round(ratio, 2), vlt_per_1000_nae = round(vlt_per_1000_nae, 1)) |>
      as.data.frame(), row.names = FALSE)
