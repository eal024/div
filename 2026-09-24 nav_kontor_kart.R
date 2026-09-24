# 2026-09-24 nav_kontor_kart.R
# Fordelingen av Navs 243 lokalkontor i Norge. Proporsjonale symboler (areal =
# ansatte i Brreg) i UTM 33 (EPSG:25833), dempet bakgrunn med sjø og naboland,
# bynavn for orientering, Oslo i innfelt utsnitt. Kartografiske regler etter
# Axis Maps Cartography Guide, Field (2014) og Wilke kap. 15.
# Kjør fra div-rota:  Rscript "2026-09-24 nav_kontor_kart.R"

# 1. Pakker --------------------------------------------------------------

library(tidyverse)
library(helper)
library(patchwork)

path_lib  <- "figurer/_lib"
path_data <- "figurer/2026-09-24_nav_kontor_kart/data"
path_out  <- "figurer/2026-09-24_nav_kontor_kart/2026-09-24_nav_kontor_fordeling.png"

source(file.path(path_lib, "theme.R"))
source(file.path(path_lib, "paletter.R"))
source(file.path(path_lib, "tekst.R"))

# 2. Projeksjon ----------------------------------------------------------

# Lengde/bredde (ETRS89) -> UTM sone 33 N, Karneys serie. Avvik fra Kartverket
# under 1 cm. Ingen sf/proj nødvendig.
fn_utm33 <- function(lon, lat) {
    a <- 6378137; f <- 1 / 298.257222101; k0 <- 0.9996; lon0 <- 15
    n <- f / (2 - f)
    A <- a / (1 + n) * (1 + n^2 / 4 + n^4 / 64)
    alpha <- c(n / 2 - 2 * n^2 / 3 + 5 * n^3 / 16, 13 * n^2 / 48 - 3 * n^3 / 5, 61 * n^3 / 240)
    phi <- lat * pi / 180
    lam <- (lon - lon0) * pi / 180
    t   <- sinh(atanh(sin(phi)) - 2 * sqrt(n) / (1 + n) * atanh(2 * sqrt(n) / (1 + n) * sin(phi)))
    xi  <- atan2(t, cos(lam))
    eta <- atanh(sin(lam) / sqrt(1 + t^2))
    s_e <- 0; s_n <- 0
    for (j in 1:3) {
        s_e <- s_e + alpha[j] * cos(2 * j * xi) * sinh(2 * j * eta)
        s_n <- s_n + alpha[j] * sin(2 * j * xi) * cosh(2 * j * eta)
    }
    tibble(x = 500000 + k0 * A * (eta + s_e), y = k0 * A * (xi + s_n))
}

# 3. Data ----------------------------------------------------------------

# GeoJSON-geometri (Polygon eller MultiPolygon) -> en rad per punkt
fn_ringer <- function(geom, id) {
    polys <- if (geom$type == "Polygon") list(geom$coordinates) else geom$coordinates
    imap_dfr(polys, \(poly, i) imap_dfr(poly, \(ring, j) {
        m <- matrix(unlist(ring), ncol = 2, byrow = TRUE)
        tibble(lon = m[, 1], lat = m[, 2], gruppe = paste(id, i, j))
    }))
}

# Fylkesgrenser fra Kartverket, allerede i EPSG:25833
df_fylker <- list.files(path_data, pattern = "^fylke25833_.*\\.json$", full.names = TRUE) |>
    map_dfr(\(f) {
        d <- jsonlite::fromJSON(f, simplifyVector = FALSE)
        fn_ringer(d$omrade, d$fylkesnummer) |> rename(x = lon, y = lat)
    })

# Naboland fra Natural Earth 50m (lon/lat), klippet i lengdegrad før projeksjon
df_naboland <- jsonlite::fromJSON(file.path(path_data, "naboland_ne50m.json"),
                                  simplifyVector = FALSE)$features |>
    keep(\(f) f$properties$admin != "Norway") |>
    map_dfr(\(f) fn_ringer(f$geometry, f$properties$admin)) |>
    mutate(lon = pmin(pmax(lon, -25), 60))

df_naboland <- bind_cols(df_naboland |> select(gruppe, lon, lat),
                         fn_utm33(df_naboland$lon, df_naboland$lat))

df_kontor <- helper::nav_kontor |>
    as_tibble() |>
    bind_cols(fn_utm33(helper::nav_kontor$lon, helper::nav_kontor$lat)) |>
    mutate(har_ansatte = !is.na(antall_ansatte)) |>
    arrange(desc(coalesce(antall_ansatte, 0L)))

df_byer <- tribble(
    ~by,            ~lon,     ~lat,    ~hjust, ~dx,     ~dy,
    "Oslo",         10.7522,  59.9139,  0,      36000,  -22000,
    "Bergen",        5.3221,  60.3913,  1,     -26000,  10000,
    "Stavanger",     5.7331,  58.9700,  1,     -26000,  -4000,
    "Kristiansand",  7.9956,  58.1599,  0.5,        0, -22000,
    "Trondheim",    10.3951,  63.4305,  0,      38000,  24000,
    "Bodø",         14.4049,  67.2804,  1,     -18000,  -4000,
    "Tromsø",       18.9553,  69.6492,  1,     -22000,  10000,
    "Alta",         23.2717,  69.9689,  0,      14000,  14000
) |> bind_cols(fn_utm33(c(10.7522, 5.3221, 5.7331, 7.9956, 10.3951, 14.4049, 18.9553, 23.2717),
                         c(59.9139, 60.3913, 58.9700, 58.1599, 63.4305, 67.2804, 69.6492, 69.9689)))

# Utsnitt Oslo og omegn (UTM 33, meter)
utsnitt <- list(x = c(238000, 278000), y = c(6632000, 6664000))
df_oslo <- df_kontor |>
    filter(between(x, utsnitt$x[1], utsnitt$x[2]), between(y, utsnitt$y[1], utsnitt$y[2]))

# 4. Plot ----------------------------------------------------------------

farge_sjo   <- "#e9f0f5"
farge_land  <- "#f4f2ee"
farge_nabo  <- "#e3e1dc"
farge_kyst  <- "#b8b4ad"
farge_data  <- okabe_ito[5]
farge_tekst <- "grey35"

fn_kart <- function(df_punkt, xlim, ylim, max_size, stroke = 0.35, grense = 0.15) {
    ggplot() +
        geom_polygon(data = df_naboland, aes(x, y, group = gruppe),
                     fill = farge_nabo, colour = farge_kyst, linewidth = grense) +
        geom_polygon(data = df_fylker, aes(x, y, group = gruppe),
                     fill = farge_land, colour = "white", linewidth = grense) +
        geom_polygon(data = df_fylker, aes(x, y, group = gruppe),
                     fill = NA, colour = farge_kyst, linewidth = grense * 0.7) +
        geom_point(data = df_punkt |> filter(!har_ansatte), aes(x, y),
                   shape = 21, fill = "white", colour = farge_data, size = 1.6, stroke = 0.5) +
        geom_point(data = df_punkt |> filter(har_ansatte), aes(x, y, size = antall_ansatte),
                   shape = 21, fill = farge_data, colour = "white", stroke = stroke) +
        scale_size_area(max_size = max_size, breaks = c(10, 50, 150),
                        labels = c("10", "50", "150 ansatte")) +
        coord_equal(xlim = xlim, ylim = ylim, expand = FALSE) +
        theme_eal_minimal() +
        theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
              axis.text.x  = element_blank(), axis.text.y  = element_blank(),
              axis.line = element_blank(), axis.ticks = element_blank(),
              panel.background = element_rect(fill = farge_sjo, colour = NA),
              plot.background  = element_rect(fill = "white", colour = NA))
}

xlim_no <- c(-280000, 1135000)
ylim_no <- c(6420000, 7960000)

p_norge <- fn_kart(df_kontor, xlim_no, ylim_no, max_size = 7.5) +
    geom_text(data = df_byer, aes(x + dx, y + dy, label = by, hjust = hjust),
              colour = farge_tekst, size = 3.1, family = fn_eal_base_family()) +
    annotate("rect", xmin = utsnitt$x[1], xmax = utsnitt$x[2],
             ymin = utsnitt$y[1], ymax = utsnitt$y[2],
             fill = NA, colour = "grey30", linewidth = 0.35) +
    # Målestokk 200 km, nede til venstre
    annotate("segment", x = -250000, xend = -50000, y = 6470000, yend = 6470000,
             colour = farge_tekst, linewidth = 0.5) +
    annotate("text", x = -150000, y = 6492000, label = "200 km",
             colour = farge_tekst, size = 2.8, family = fn_eal_base_family()) +
    guides(size = guide_legend(override.aes = list(fill = farge_data, colour = "white"))) +
    theme(legend.position = c(0.88, 0.11), legend.direction = "vertical",
          legend.key.height = unit(0.75, "cm"),
          legend.text = element_text(colour = farge_tekst, size = 9),
          legend.background = element_rect(fill = NA, colour = NA))

p_oslo <- fn_kart(df_oslo, utsnitt$x, utsnitt$y, max_size = 7.5, stroke = 0.4, grense = 0.25) +
    guides(size = "none") +
    annotate("text", x = utsnitt$x[1] + 1500, y = utsnitt$y[2] - 2500, label = "Oslo og omegn",
             hjust = 0, colour = farge_tekst, size = 3, family = fn_eal_base_family()) +
    theme(panel.border = element_rect(fill = NA, colour = "grey30", linewidth = 0.35))

p <- p_norge +
    inset_element(p_oslo, left = 0.02, bottom = 0.64, right = 0.36, top = 0.88) +
    plot_annotation(
        title    = "Nav har 243 lokalkontor: store i byene,\nmange små langs kysten og i innlandet",
        subtitle = paste0("Ett symbol per kontor, plassert på beliggenhetsadressen.\nArealet viser antall ansatte ",
                          "registrert i Enhetsregisteret. Hule ringer: ", sum(!df_kontor$har_ansatte),
                          " kontor uten registrert antall."),
        caption  = paste0(kilde_caption("nav.no (NORG), Enhetsregisteret, Kartverket, Natural Earth", "2026-09-24"),
                          ". Projeksjon UTM 33 (EPSG:25833)."),
        theme = theme(
            plot.title    = element_text(size = 14, face = "bold", colour = "grey15", lineheight = 1.05,
                                         family = fn_eal_base_family(), hjust = 0),
            plot.subtitle = element_text(size = 10, colour = farge_tekst, lineheight = 1.15,
                                         family = fn_eal_base_family(), margin = margin(b = 6)),
            plot.caption  = element_text(size = 7.5, colour = "grey50", hjust = 0,
                                         family = fn_eal_base_family()),
            plot.background = element_rect(fill = "white", colour = NA),
            plot.margin = margin(8, 8, 6, 8)
        )
    )

# 5. Lagre ---------------------------------------------------------------

ggsave(path_out, p, width = 18, height = 25, units = "cm", dpi = 300, bg = "white")
cat("Skrevet:", path_out, "\n")
