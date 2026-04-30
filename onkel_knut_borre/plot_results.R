# plot_results.R
# Lager plot over onkel Knut Børres løp- og sykkelresultater.
# Leser results.csv i samme mappe og skriver to PNG-filer.

library(tidyverse)
library(lubridate)

args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
here <- if (length(file_arg) > 0) normalizePath(dirname(file_arg)) else getwd()

results_path <- file.path(here, "results.csv")
stopifnot(file.exists(results_path))

raw <- read_csv(results_path, show_col_types = FALSE)

parse_hms <- function(x) {
  parts <- str_split_fixed(x, ":", 3)
  storage.mode(parts) <- "numeric"
  parts[, 1] * 3600 + parts[, 2] * 60 + parts[, 3]
}

dat <- raw |>
  filter(!is.na(tid_hms), tid_hms != "") |>
  mutate(
    dato = ymd(dato),
    sekunder = parse_hms(tid_hms),
    fart_kmt = distanse_km / (sekunder / 3600),
    tempo_min_per_km = (sekunder / 60) / distanse_km
  )

if (nrow(dat) == 0) {
  message("results.csv mangler utfylte tider — plot blir tomt. Fyll inn tid_hms (hh:mm:ss).")
}

# Plot 1: tidslinje
p1 <- raw |>
  mutate(dato = ymd(dato)) |>
  ggplot(aes(x = dato, y = event, color = type, size = distanse_km)) +
  geom_point(alpha = 0.8) +
  scale_size_continuous(range = c(3, 8)) +
  labs(
    title = "Onkel Knut Børres løp og ritt",
    x = "År", y = NULL,
    color = "Type", size = "Distanse (km)"
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(here, "plot_tidslinje.png"), p1, width = 9, height = 5, dpi = 150)

# Plot 2: tempo / fart
if (nrow(dat) > 0) {
  p2 <- dat |>
    mutate(
      ytdi = if_else(type == "løp", tempo_min_per_km, fart_kmt),
      ymerk = if_else(type == "løp", "Tempo (min/km)", "Fart (km/t)")
    ) |>
    ggplot(aes(x = dato, y = ytdi, color = event)) +
    geom_point(size = 3) +
    geom_line(aes(group = event), linetype = "dashed") +
    facet_wrap(~ ymerk, scales = "free_y") +
    labs(title = "Tempo (løp) og fart (sykkel)", x = "År", y = NULL) +
    theme_minimal(base_size = 12)

  ggsave(file.path(here, "plot_tempo.png"), p2, width = 9, height = 5, dpi = 150)
}

message("Ferdig. Plot lagret i ", here)
