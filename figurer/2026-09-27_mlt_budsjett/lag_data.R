# lag_data.R
# Midlertidig lønnstilskudd (MLT) per fylke og kommune, januar 2024 til august
# 2026, og andre tiltak i samme periode. Spørsmålet er om fylker som brukte opp
# budsjettet sommeren 2025 kuttet plasser fra juni og ut året, om nabokommuner
# på hver side av en fylkesgrense fikk ulik behandling, og om kuttet ble
# erstattet av andre tiltak. Leser Nav-filene i data/raw/ og skriver JSON til
# data/web/ som index.qmd leser med Observable Plot.
#
# Kilder (nav.no, åpne data, «Tiltaksdeltakere» og arkivet per år):
#   TILT100 Tiltaksdeltakere. Hovedgruppe og demografi (ark «Tiltaksdeltakere og kommune»: alle tiltak)
#   TILT110 lønnstilskudd, TILT120 arbeidspraksis, TILT130 opplæring, TILT140 oppfølging,
#   TILT150 avklaring, TILT160 arbeidsrettet rehabilitering, TILT170 tilrettelagt arbeid,
#   TILT180 jobbskaping og tilrettelegging. Ark «Tiltak og fylke» (alle år) og
#   «Tiltak og kommune» (fra 2025-fila). Desember-filene dekker hele året.
#   Celler under 4 er prikket («*») og leses som NA.
#   HARB100 Sesongjusterte hovedtall om arbeidsmarkedet (august 2026): helt ledige, delvis
#   ledige, tiltaksdeltakere og arbeidssøkere i alt per måned, sesongjustert, brudd april 2025.
#   kommuner.geojson: 357 kommunepolygoner fra Kartverket, forenklet, kopiert fra
#   div/figurer/2026-09-27_nav_butikker_kart/data/web/. Brukes til nabopar.
# Kjør fra denne mappa: Rscript lag_data.R

suppressMessages({ library(tidyverse); library(readxl); library(jsonlite) })

mnd_navn <- c("januar", "februar", "mars", "april", "mai", "juni", "juli",
              "august", "september", "oktober", "november", "desember")

fylke_nr <- c("03" = "Oslo", "11" = "Rogaland", "15" = "Møre og Romsdal", "18" = "Nordland",
              "31" = "Østfold", "32" = "Akershus", "33" = "Buskerud", "34" = "Innlandet",
              "39" = "Vestfold", "40" = "Telemark", "42" = "Agder", "46" = "Vestland",
              "50" = "Trøndelag", "55" = "Troms", "56" = "Finnmark")

fn_navn <- function(x) {
    x |> str_remove("^\\d+\\s+") |> str_remove("\\s+-\\s+.*$") |> str_trim()
}

# 1. Lesefunksjon for blokkene i Nav-arkene -------------------------------

# Hvert ark har blokker som starter med «I alt <tiltak>» i kolonne 1, en
# headerrad med månedsnavn over første blokk, og rader per enhet under.
# Returnerer enhet × periode × antall for én blokk.
fn_blokk <- function(fil, aar, ark, blokk) {
    x <- as.data.frame(suppressMessages(read_excel(fil, sheet = ark, col_names = FALSE)))
    i0  <- which(x[[1]] == blokk)[1]
    hdr <- max(which(x[[2]] == "Gjennomsnitt hittil i år" & seq_len(nrow(x)) < i0))
    mnd <- as.character(x[hdr, 3:ncol(x)])
    mnd <- mnd[str_to_lower(mnd) %in% mnd_navn]
    i1  <- i0 + 1
    while (i1 <= nrow(x) && !is.na(x[i1, 1])) i1 <- i1 + 1
    x[(i0 + 1):(i1 - 1), c(1, 3:(2 + length(mnd)))] |>
        set_names(c("enhet", mnd)) |>
        pivot_longer(-enhet, names_to = "mnd", values_to = "antall") |>
        mutate(aar     = aar,
               mnd_nr  = match(str_to_lower(mnd), mnd_navn),
               periode = sprintf("%d-%02d-01", aar, mnd_nr),
               prikket = antall == "*",
               antall  = suppressWarnings(as.integer(antall))) |>
        select(enhet, periode, antall, prikket)
}

fn_blokker <- function(fil, ark) {
    x <- as.data.frame(suppressMessages(read_excel(fil, sheet = ark, col_names = FALSE)))
    unique(x[[1]][str_starts(coalesce(x[[1]], ""), "I alt")])
}

# Filer og hvilken tiltaksgruppe hver blokk hører til
filer <- expand_grid(kode = c("tilt100", "tilt110", "tilt120", "tilt130", "tilt140",
                              "tilt150", "tilt160", "tilt170", "tilt180"),
                     tibble(stempel = c("202412", "202512", "202608"), aar = c(2024, 2025, 2026))) |>
    mutate(fil = sprintf("data/raw/%s_%s.xlsx", kode, stempel))

fn_gruppe <- function(kode, blokk) {
    case_when(
        kode == "tilt110" & blokk == "I alt midlertidig lønnstilskudd" ~ "Midlertidig lønnstilskudd",
        kode == "tilt110" & blokk == "I alt varig lønnstilskudd"       ~ "Varig lønnstilskudd",
        kode == "tilt110"                                              ~ "Tilskudd til sommerjobb",
        kode == "tilt120" & blokk == "I alt arbeidstrening"            ~ "Arbeidstrening",
        kode == "tilt120"                                              ~ "Arbeidsforberedende trening",
        kode == "tilt130"                                              ~ "Opplæring",
        kode == "tilt140"                                              ~ "Oppfølging",
        kode == "tilt150"                                              ~ "Avklaring",
        kode == "tilt160"                                              ~ "Arbeidsrettet rehabilitering",
        kode == "tilt170"                                              ~ "Varig tilrettelagt arbeid",
        kode == "tilt180"                                              ~ "Tilrettelegging og egenetablering",
        kode == "tilt100"                                              ~ "Alle tiltak"
    )
}

# 2. Fylke: alle tiltaksgrupper, januar 2024 til august 2026 ---------------

df_fylke_alle <- filer |>
    filter(kode != "tilt100") |>
    pmap_dfr(\(kode, stempel, aar, fil) {
        map_dfr(fn_blokker(fil, "Tiltak og fylke"), \(b)
            fn_blokk(fil, aar, "Tiltak og fylke", b) |> mutate(kode = kode, blokk = b))
    }) |>
    mutate(fylke = fn_navn(enhet), gruppe = fn_gruppe(kode, blokk)) |>
    filter(fylke %in% fylke_nr) |>
    group_by(fylke, gruppe, periode) |>
    summarise(antall = sum(antall, na.rm = TRUE), n_prikket = sum(prikket), .groups = "drop") |>
    arrange(gruppe, fylke, periode)

df_mlt <- df_fylke_alle |>
    filter(gruppe %in% c("Midlertidig lønnstilskudd", "Varig lønnstilskudd")) |>
    select(fylke, gruppe, periode, antall)

df_landet <- df_fylke_alle |>
    group_by(gruppe, periode) |>
    summarise(antall = sum(antall), .groups = "drop")

# 3. Halvår per fylke: første mot andre halvår 2025, med 2024 som sesongkontroll

fn_halvaar <- function(p) {
    case_when(p >= "2024-01-01" & p <= "2024-06-01" ~ "h1_2024",
              p >= "2024-07-01" & p <= "2024-12-01" ~ "h2_2024",
              p >= "2025-01-01" & p <= "2025-06-01" ~ "h1_2025",
              p >= "2025-07-01" & p <= "2025-12-01" ~ "h2_2025",
              p >= "2026-01-01"                     ~ "h1_2026")
}

df_fylke_tiltak <- df_fylke_alle |>
    mutate(halvaar = fn_halvaar(periode)) |>
    group_by(fylke, gruppe, halvaar) |>
    summarise(antall = mean(antall), .groups = "drop") |>
    pivot_wider(names_from = halvaar, values_from = antall) |>
    mutate(endring_2025_abs = h2_2025 - h1_2025,
           endring_2025_pst = 100 * (h2_2025 / h1_2025 - 1),
           endring_2024_pst = 100 * (h2_2024 / h1_2024 - 1),
           endring_2026_pst = 100 * (h1_2026 / h2_2025 - 1))

df_fylke_halvaar <- df_mlt |>
    filter(gruppe == "Midlertidig lønnstilskudd") |>
    left_join(df_fylke_alle |> filter(gruppe == "Midlertidig lønnstilskudd") |>
                  select(fylke, periode), by = c("fylke", "periode")) |>
    mutate(halvaar = fn_halvaar(periode)) |>
    group_by(fylke, halvaar) |>
    summarise(antall = mean(antall), .groups = "drop") |>
    pivot_wider(names_from = halvaar, values_from = antall) |>
    left_join(df_mlt |> filter(gruppe == "Midlertidig lønnstilskudd", periode %in% c("2025-05-01", "2025-12-01")) |>
                  mutate(mnd = if_else(periode == "2025-05-01", "mai_2025", "des_2025")) |>
                  select(fylke, mnd, antall) |> pivot_wider(names_from = mnd, values_from = antall),
              by = "fylke") |>
    mutate(endring_2025_pst = 100 * (h2_2025 / h1_2025 - 1),
           endring_2024_pst = 100 * (h2_2024 / h1_2024 - 1),
           endring_mai_des_pst = 100 * (des_2025 / mai_2025 - 1),
           endring_2026_pst = 100 * (h1_2026 / h2_2025 - 1),
           # Differansen mot 2024 fjerner sesongen: hvor mye dypere var 2025-kuttet?
           kutt_utover_sesong = endring_2025_pst - endring_2024_pst) |>
    arrange(endring_2025_pst)

# 4. Kommune: lønnstilskudd og alle tiltak, 2025 og 2026 -------------------

fn_kommune <- function(kode, ark, blokk_filter = NULL) {
    filer |>
        filter(kode == .env$kode, aar >= 2025) |>
        pmap_dfr(\(kode, stempel, aar, fil) {
            blokker <- fn_blokker(fil, ark)
            if (!is.null(blokk_filter)) blokker <- blokker[blokker %in% blokk_filter]
            map_dfr(blokker, \(b) fn_blokk(fil, aar, ark, b) |> mutate(kode = kode, blokk = b))
        }) |>
        mutate(knr = str_extract(enhet, "^\\d{4}"), gruppe = fn_gruppe(kode, blokk)) |>
        filter(!is.na(knr))
}

df_kom_mlt <- fn_kommune("tilt110", "Tiltak og kommune",
                         c("I alt midlertidig lønnstilskudd", "I alt varig lønnstilskudd")) |>
    select(knr, gruppe, periode, antall, prikket)

df_kom_alle <- fn_kommune("tilt100", "Tiltaksdeltakere og kommune") |>
    select(knr, periode, alle = antall, alle_prikket = prikket)

# Andre tiltaksgrupper per kommune: summert over blokker, prikkede celler som 0 og telt
df_kom_andre <- c("tilt120", "tilt130", "tilt140", "tilt150", "tilt160", "tilt170") |>
    map_dfr(\(k) fn_kommune(k, "Tiltak og kommune")) |>
    group_by(knr, gruppe, periode) |>
    summarise(antall = sum(antall, na.rm = TRUE), n_prikket = sum(prikket), .groups = "drop")

# Kommunenavn fra 2026-fila (nyeste), fylke fra de to første sifrene
df_kom_navn <- fn_kommune("tilt100", "Tiltaksdeltakere og kommune") |>
    filter(periode == max(periode)) |>
    transmute(knr, kommune = fn_navn(enhet), fnr = str_sub(knr, 1, 2), fylke = fylke_nr[fnr]) |>
    distinct(knr, .keep_all = TRUE)

df_kom_serie <- df_kom_mlt |>
    filter(gruppe == "Midlertidig lønnstilskudd") |>
    select(knr, periode, mlt = antall, mlt_prikket = prikket) |>
    full_join(df_kom_alle, by = c("knr", "periode")) |>
    inner_join(df_kom_navn, by = "knr") |>
    mutate(andre = alle - coalesce(mlt, 0L)) |>
    arrange(knr, periode)

df_kom_halvaar <- df_kom_serie |>
    mutate(halvaar = fn_halvaar(periode)) |>
    group_by(knr, kommune, fylke, halvaar) |>
    summarise(mlt = mean(mlt, na.rm = TRUE), alle = mean(alle, na.rm = TRUE),
              andre = mean(andre, na.rm = TRUE), n_prikket = sum(mlt_prikket), .groups = "drop") |>
    mutate(mlt = if_else(is.nan(mlt), NA_real_, mlt)) |>
    pivot_wider(names_from = halvaar, values_from = c(mlt, alle, andre, n_prikket)) |>
    mutate(mlt_endring_abs = mlt_h2_2025 - mlt_h1_2025,
           mlt_endring_pst = 100 * (mlt_h2_2025 / mlt_h1_2025 - 1),
           andre_endring_abs = andre_h2_2025 - andre_h1_2025,
           andre_endring_pst = 100 * (andre_h2_2025 / andre_h1_2025 - 1),
           alle_endring_pst = 100 * (alle_h2_2025 / alle_h1_2025 - 1),
           mlt_2026_pst = 100 * (mlt_h1_2026 / mlt_h2_2025 - 1),
           prikket_2025 = n_prikket_h1_2025 + n_prikket_h2_2025,
           # Bare kommuner med minst 15 plasser i snitt første halvår og ingen prikking i 2025
           paalitelig = !is.na(mlt_h1_2025) & mlt_h1_2025 >= 15 & prikket_2025 == 0) |>
    arrange(mlt_endring_pst)

# Andre tiltaksgrupper per kommune, halvår 2025
df_kom_andre_halvaar <- df_kom_andre |>
    mutate(halvaar = fn_halvaar(periode)) |>
    filter(halvaar %in% c("h1_2025", "h2_2025")) |>
    group_by(knr, gruppe, halvaar) |>
    summarise(antall = mean(antall), n_prikket = sum(n_prikket), .groups = "drop") |>
    pivot_wider(names_from = halvaar, values_from = c(antall, n_prikket)) |>
    mutate(endring_abs = antall_h2_2025 - antall_h1_2025,
           endring_pst = 100 * (antall_h2_2025 / antall_h1_2025 - 1)) |>
    inner_join(df_kom_navn, by = "knr")

# 5. Nabokommuner: par som deler grense, fra kommunepolygonene ----------------

# Polygonene er forenklet med felles topologi, så to kommuner som grenser til
# hverandre deler minst ett hjørnepunkt. Naboskap = felles koordinat (avrundet).
g <- fromJSON("data/raw/kommuner.geojson", simplifyVector = FALSE)

fn_punkter <- function(f) {
    co <- f$geometry$coordinates
    ringer <- if (f$geometry$type == "Polygon") co else purrr::list_flatten(co)
    pts <- do.call(rbind, map(ringer, \(r) matrix(unlist(r), ncol = 2, byrow = TRUE)))
    tibble(knr = f$properties$knr, nokkel = sprintf("%.5f_%.5f", pts[, 1], pts[, 2])) |> distinct()
}

df_pkt <- map_dfr(g$features, fn_punkter)

df_nabo <- df_pkt |>
    inner_join(df_pkt, by = "nokkel", relationship = "many-to-many") |>
    filter(knr.x < knr.y) |>
    distinct(knr_a = knr.x, knr_b = knr.y)

fn_side <- function(suffix) {
    df_kom_halvaar |>
        select(knr, kommune, fylke, mlt_h1_2025, mlt_h2_2025, mlt_endring_pst, paalitelig) |>
        rename_with(\(v) paste0(v, suffix))
}

df_nabo_par <- df_nabo |>
    inner_join(fn_side("_a"), by = "knr_a") |>
    inner_join(fn_side("_b"), by = "knr_b") |>
    filter(paalitelig_a, paalitelig_b) |>
    mutate(differanse = mlt_endring_pst_a - mlt_endring_pst_b,
           kryss_fylke = fylke_a != fylke_b) |>
    select(-paalitelig_a, -paalitelig_b) |>
    arrange(desc(abs(differanse)))


# 5b. Sesongjusterte hovedtall: hvor ble det av deltakerne? -------------------

# HARB100 har ett ark per serie, år som rader og måneder som kolonner. Tiltaks-
# deltakere er Navs definisjon i denne fila (arbeidssøkere og andre på tiltak,
# uten ARR, tilrettelegging og nedsatt arbeidsevne på tiltak).
fn_harb <- function(ark, navn) {
    x <- as.data.frame(suppressMessages(read_excel("data/raw/harb100_202608.xlsx", sheet = ark, col_names = FALSE)))
    hdr <- which(x[[2]] == "Januar")[1]
    mnd <- as.character(x[hdr, 2:13])
    x[(hdr + 1):nrow(x), 1:13] |>
        set_names(c("aar", mnd)) |>
        filter(!is.na(aar)) |>
        pivot_longer(-aar, names_to = "mnd", values_to = "verdi") |>
        mutate(aar     = as.integer(aar),
               mnd_nr  = match(str_to_lower(mnd), mnd_navn),
               periode = sprintf("%d-%02d-01", aar, mnd_nr),
               verdi   = suppressWarnings(as.numeric(verdi))) |>
        filter(!is.na(verdi), aar >= 2022) |>
        select(periode, {{ navn }} := verdi)
}

df_harb <- fn_harb("Helt ledige", helt_ledige) |>
    inner_join(fn_harb("Delvis ledige", delvis_ledige), by = "periode") |>
    inner_join(fn_harb("Helt ledige og tiltaksdeltakere", helt_og_tiltak), by = "periode") |>
    inner_join(fn_harb("Arbeidssøkere", arbeidssokere), by = "periode") |>
    mutate(tiltak = helt_og_tiltak - helt_ledige) |>
    select(periode, helt_ledige, delvis_ledige, tiltak, arbeidssokere) |>
    arrange(periode)

# 6. Skriv -------------------------------------------------------------------

write_json(df_mlt,                "data/web/mlt_fylke.json",            digits = NA)
write_json(df_landet,             "data/web/landet_tiltak.json",        digits = NA)
write_json(df_fylke_halvaar,      "data/web/fylke_halvaar.json",        digits = NA)
write_json(df_fylke_tiltak,       "data/web/fylke_tiltak_halvaar.json", digits = NA)
write_json(df_kom_serie,          "data/web/kommune_serie.json",        digits = NA, na = "null")
write_json(df_kom_halvaar,        "data/web/kommune_halvaar.json",      digits = NA, na = "null")
write_json(df_kom_andre_halvaar,  "data/web/kommune_tiltak_halvaar.json", digits = NA, na = "null")
write_json(df_nabo_par,           "data/web/nabo_par.json",             digits = NA)
write_json(df_harb,               "data/web/hovedtall_sesongjustert.json", digits = NA)
write_json(list(sist_oppdatert = max(df_mlt$periode), generert = format(Sys.time(), "%Y-%m-%d"),
                n_kommuner = nrow(df_kom_halvaar), n_paalitelig = sum(df_kom_halvaar$paalitelig),
                n_nabopar = nrow(df_nabo_par), n_nabopar_kryss = sum(df_nabo_par$kryss_fylke)),
           "data/web/metadata.json", auto_unbox = TRUE)

# 7. Kontrollutskrift --------------------------------------------------------

r1 <- \(v) round(v, 1)
cat("\n== Landet, midlertidig lønnstilskudd per måned ==\n")
print(df_landet |> filter(gruppe == "Midlertidig lønnstilskudd") |> select(periode, antall) |>
          as.data.frame(), row.names = FALSE)
cat("\n== Fylke: første mot andre halvår, midlertidig lønnstilskudd ==\n")
print(df_fylke_halvaar |> mutate(across(where(is.numeric), r1)) |> as.data.frame(), row.names = FALSE)
cat("\n== Fylke × tiltaksgruppe: endring H1 til H2 2025 i prosent (2024 i parentes) ==\n")
print(df_fylke_tiltak |> mutate(v = sprintf("%.0f (%.0f)", endring_2025_pst, endring_2024_pst)) |>
          select(fylke, gruppe, v) |> pivot_wider(names_from = gruppe, values_from = v) |> as.data.frame(), row.names = FALSE)
cat("\n== Kommuner: pålitelige =", sum(df_kom_halvaar$paalitelig), "av", nrow(df_kom_halvaar), "==\n")
print(df_kom_halvaar |> filter(paalitelig) |> select(kommune, fylke, mlt_h1_2025, mlt_h2_2025, mlt_endring_pst,
                                                     andre_h1_2025, andre_h2_2025, andre_endring_pst) |>
          mutate(across(where(is.numeric), r1)) |> as.data.frame(), row.names = FALSE)
cat("\n== Nabopar over fylkesgrense, størst forskjell ==\n")
print(df_nabo_par |> filter(kryss_fylke) |> head(20) |>
          select(kommune_a, fylke_a, mlt_endring_pst_a, kommune_b, fylke_b, mlt_endring_pst_b, differanse) |>
          mutate(across(where(is.numeric), r1)) |> as.data.frame(), row.names = FALSE)
cat("\n== Nabopar innen fylke, størst forskjell ==\n")
print(df_nabo_par |> filter(!kryss_fylke) |> head(15) |>
          select(kommune_a, kommune_b, fylke_a, mlt_endring_pst_a, mlt_endring_pst_b, differanse) |>
          mutate(across(where(is.numeric), r1)) |> as.data.frame(), row.names = FALSE)
cat("\n== Sesongjusterte hovedtall, juni og desember ==\n")
print(df_harb |> filter(str_detect(periode, "-(06|12)-"), periode >= "2024-01-01") |> as.data.frame(), row.names = FALSE)
cat("\nnabopar:", nrow(df_nabo), "| med pålitelige tall:", nrow(df_nabo_par), "| kryss fylke:", sum(df_nabo_par$kryss_fylke), "\n")
