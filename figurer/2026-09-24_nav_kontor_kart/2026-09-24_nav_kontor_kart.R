# 2026-09-24_nav_kontor_kart.R
# Kart over Navs 243 lokalkontor: hvor de ligger, og om publikum kan komme
# uten timeavtale. Fylkesgrenser fra Kartverket (kommuneinfo-API, EPSG:4258),
# kontorkoordinater fra helper::nav_kontor (Kartverkets adresse-API).

# 1. Pakker --------------------------------------------------------------

library(tidyverse)
library(helper)
library(patchwork)

path_lib  <- "../_lib"
path_data <- "data"
path_out  <- "2026-09-24_nav_kontor_kart.png"

source(file.path(path_lib, "theme.R"))
source(file.path(path_lib, "paletter.R"))
source(file.path(path_lib, "tekst.R"))

# 2. Data ----------------------------------------------------------------

# Fylkesgrenser: en rad per punkt, med polygon-id slik at geom_polygon
# tegner hver ring for seg (fylkene er MultiPolygon med øyer).
fn_les_fylke <- function(fil) {
    d <- jsonlite::fromJSON(fil, simplifyVector = FALSE)
    imap_dfr(d$omrade$coordinates, \(poly, i) {
        imap_dfr(poly, \(ring, j) {
            m <- matrix(unlist(ring), ncol = 2, byrow = TRUE)
            tibble(lon = m[, 1], lat = m[, 2], ring = j)
        }) |> mutate(poly = i)
    }) |>
        mutate(fylke = d$fylkesnavn, gruppe = paste(fylke, poly, ring))
}

df_fylker <- list.files(path_data, pattern = "^fylke_.*\\.json$", full.names = TRUE) |>
    map_dfr(fn_les_fylke)

df_kontor <- nav_kontor |>
    as_tibble() |>
    mutate(mottak = if_else(dropin, "drop-in", "kun timeavtale"))

# Utsnitt Oslo-området: alle kontor innenfor ruta
utsnitt <- list(lon = c(10.40, 11.05), lat = c(59.78, 60.03))
df_oslo <- df_kontor |>
    filter(between(lon, utsnitt$lon[1], utsnitt$lon[2]),
           between(lat, utsnitt$lat[1], utsnitt$lat[2]))

# 3. Plot ----------------------------------------------------------------

farger <- c("drop-in" = okabe_ito[5], "kun timeavtale" = okabe_ito[6])

fn_kart <- function(df_punkt, xlim, ylim, punkt_str) {
    ggplot() +
        geom_polygon(data = df_fylker, aes(lon, lat, group = gruppe),
                     fill = "grey93", colour = "white", linewidth = 0.25) +
        geom_point(data = df_punkt, aes(lon, lat, colour = mottak),
                   size = punkt_str, alpha = 0.85) +
        scale_colour_manual(values = farger, guide = "none") +
        coord_quickmap(xlim = xlim, ylim = ylim, expand = FALSE) +
        theme_eal_minimal() +
        theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
              axis.text.x  = element_blank(), axis.text.y  = element_blank(),
              axis.line = element_blank(), axis.ticks = element_blank(),
              plot.background = element_rect(fill = "white", colour = NA))
}

p_norge <- fn_kart(df_kontor, xlim = c(4.3, 31.5), ylim = c(57.8, 71.3), punkt_str = 1.9) +
    annotate("rect", xmin = utsnitt$lon[1], xmax = utsnitt$lon[2],
             ymin = utsnitt$lat[1], ymax = utsnitt$lat[2],
             fill = NA, colour = "grey40", linewidth = 0.3) +
    labs(subtitle = subtitle_med_farger(
             sprintf("%d lokalkontor. %d tar imot publikum med drop-in, %d kun etter timeavtale.",
                     nrow(df_kontor), sum(df_kontor$dropin), sum(!df_kontor$dropin)),
             farger = list("drop-in" = farger[["drop-in"]], "kun etter timeavtale" = farger[["kun timeavtale"]])),
         caption = paste0(kilde_caption("nav.no (NORG), Kartverket", "2026-09-24"),
                          ".\nEtt punkt per kontor (beliggenhetsadresse). Ramme og utsnitt: Oslo og omegn.")) +
    theme(plot.subtitle = ggtext::element_markdown(size = 11, colour = "grey30", lineheight = 1.2),
          plot.caption = element_text(size = 8))

p_oslo <- fn_kart(df_oslo, xlim = utsnitt$lon, ylim = utsnitt$lat, punkt_str = 2.2) +
    theme(panel.border = element_rect(fill = NA, colour = "grey40", linewidth = 0.3))

p <- p_norge + inset_element(p_oslo, left = 0.50, bottom = 0.03, right = 0.995, top = 0.36)

# 4. Lagre ---------------------------------------------------------------

ggsave(path_out, p, width = 16, height = 22, units = "cm", dpi = 300, bg = "white")
cat("Skrevet:", path_out, "\n")
