# 2026-09-24 nav_kontor_kart.R
# Fordelingen av Navs 243 lokalkontor i Norge: kart med ett punkt per kontor
# (st??rrelse = ansatte i Brreg) og stolper med antall kontor per fylke.
# Kj??r fra div-rota:  Rscript "2026-09-24 nav_kontor_kart.R"

# 1. Pakker --------------------------------------------------------------

library(tidyverse)
library(helper)
library(patchwork)

path_lib    <- "figurer/_lib"
path_fylker <- "figurer/2026-09-24_nav_kontor_kart/data"
path_out    <- "figurer/2026-09-24_nav_kontor_kart/2026-09-24_nav_kontor_fordeling.png"

source(file.path(path_lib, "theme.R"))
source(file.path(path_lib, "paletter.R"))
source(file.path(path_lib, "tekst.R"))

# 2. Data ----------------------------------------------------------------

# Fylkesgrenser (Kartverket, EPSG:4258): en rad per punkt, en gruppe per ring
fn_les_fylke <- function(fil) {
    d <- jsonlite::fromJSON(fil, simplifyVector = FALSE)
    imap_dfr(d$omrade$coordinates, \(poly, i) {
        imap_dfr(poly, \(ring, j) {
            m <- matrix(unlist(ring), ncol = 2, byrow = TRUE)
            tibble(lon = m[, 1], lat = m[, 2], ring = j)
        }) |> mutate(poly = i)
    }) |>
        mutate(fylkesnr = d$fylkesnummer, fylke = d$fylkesnavn,
               gruppe = paste(fylkesnr, poly, ring))
}

df_fylker <- list.files(path_fylker, pattern = "^fylke_.*\\.json$", full.names = TRUE) |>
    map_dfr(fn_les_fylke)

df_fylkesnavn <- df_fylker |> distinct(fylkesnr, fylke)

# Kontor: fylke fra de to f??rste sifrene i kommunenummeret (2024-inndeling)
df_kontor <- helper::nav_kontor |>
    as_tibble() |>
    mutate(fylkesnr = str_sub(kommunenr, 1, 2),
           ansatte  = coalesce(antall_ansatte, 0L)) |>
    left_join(df_fylkesnavn, join_by(fylkesnr))

df_per_fylke <- df_kontor |>
    count(fylke, name = "kontor") |>
    mutate(fylke = fct_reorder(fylke, kontor))

# 3. Plot ----------------------------------------------------------------

farge_punkt <- okabe_ito[5]

p_kart <- ggplot() +
    geom_polygon(data = df_fylker, aes(lon, lat, group = gruppe),
                 fill = "grey92", colour = "white", linewidth = 0.3) +
    geom_point(data = df_kontor |> arrange(desc(ansatte)),
               aes(lon, lat, size = ansatte),
               colour = farge_punkt, alpha = 0.55, stroke = 0) +
    scale_size_area(max_size = 7, breaks = c(10, 50, 150),
                    labels = c("10", "50", "150 ansatte")) +
    coord_quickmap(xlim = c(4.3, 31.5), ylim = c(57.8, 71.3), expand = FALSE) +
    theme_eal_minimal() +
    theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
          axis.text.x  = element_blank(), axis.text.y  = element_blank(),
          axis.line = element_blank(), axis.ticks = element_blank(),
          legend.position = c(0.80, 0.28), legend.direction = "vertical",
          legend.text = element_text(colour = "grey40", size = 9),
          plot.background = element_rect(fill = "white", colour = NA))

p_stolper <- ggplot(df_per_fylke, aes(kontor, fylke)) +
    geom_col(fill = farge_punkt, alpha = 0.85, width = 0.7) +
    geom_text(aes(label = kontor), hjust = -0.35, colour = "grey30", size = 3.2) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.18))) +
    labs(x = "Lokalkontor per fylke", y = NULL) +
    theme_eal_minimal(base_size = 11) +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          axis.line.x = element_blank(), axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title.x = element_text(hjust = 0, colour = "grey30", size = 10))

p <- p_kart + p_stolper +
    plot_layout(widths = c(1.9, 1)) +
    plot_annotation(
        subtitle = sprintf(paste0(
            "%d lokalkontor, ett punkt per kontor. St??rrelsen viser antall ansatte ",
            "registrert i Enhetsregisteret\n(%d kontor uten registrert antall vises som minste punkt)."),
            nrow(df_kontor), sum(is.na(df_kontor$antall_ansatte))),
        caption = paste0(kilde_caption("nav.no (NORG), Enhetsregisteret, Kartverket", "2026-09-24"),
                         ". Fylke etter kommunenummer, 2024-inndeling."),
        theme = theme(plot.subtitle = element_text(size = 11, colour = "grey30", lineheight = 1.15),
                      plot.caption  = element_text(size = 8, colour = "grey50", hjust = 0),
                      plot.background = element_rect(fill = "white", colour = NA))
    )

# 4. Lagre ---------------------------------------------------------------

#ggsave(path_out, p, width = 26, height = 20, units = "cm", dpi = 300, bg = "white")
cat("Skrevet:", path_out, "\n")
