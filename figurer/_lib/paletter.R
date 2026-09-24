# paletter.R
# Paletter og fargeskalaer for eal-skillen.
# Default: Okabe-Ito (Wilkes anbefaling, kolorblindt trygg, 8 farger).
# Alternativ: nav_branded (fargene fra https://eirikala.quarto.pub/...).
# Hold synkronisert med _lib/eal_palette.js for Observable Plot.

# 1. Palett-konstanter ---------------------------------------------------

# Okabe-Ito (Wilke kap. 4): kolorblindt-trygg, 8 farger
okabe_ito <- c(
    "#E69F00",  # oransje
    "#56B4E9",  # himmelblaa
    "#009E73",  # bluegreen
    "#F0E442",  # gul
    "#0072B2",  # blaa
    "#D55E00",  # rodorange
    "#CC79A7",  # rosa
    "#000000"   # svart
)

# Nav-branded: fra eirikala.quarto.pub/along-the-way-in-time/arbeidsmarkedstiltak/
nav_branded <- c(
    arbeidssoekere       = "#2c3e50",  # moerk blaagra
    nedsatt_arbeidsevne  = "#1a6b4a",  # moerkegroenn
    referanse            = "#9ca3a3"   # lysegra
)

# 2. Skalafunksjoner -----------------------------------------------------

# Kvalitative (uordnede kategorier)
scale_color_eal_qualitative <- function(palette = c("okabe_ito", "nav_branded"), ...) {
    palette <- match.arg(palette)
    farger  <- if (palette == "okabe_ito") okabe_ito else unname(nav_branded)
    ggplot2::scale_color_manual(values = farger, ...)
}

scale_fill_eal_qualitative <- function(palette = c("okabe_ito", "nav_branded"), ...) {
    palette <- match.arg(palette)
    farger  <- if (palette == "okabe_ito") okabe_ito else unname(nav_branded)
    ggplot2::scale_fill_manual(values = farger, ...)
}

# Sekvensielle (ordnede, kontinuerlige) — viridis (Wilke + Healy)
scale_color_eal_sequential <- function(...) {
    ggplot2::scale_color_viridis_c(...)
}

scale_fill_eal_sequential <- function(...) {
    ggplot2::scale_fill_viridis_c(...)
}

# Divergerende (meningsfullt midtpunkt) — RdBu fra ColorBrewer
scale_color_eal_diverging <- function(...) {
    ggplot2::scale_color_distiller(palette = "RdBu", ...)
}

scale_fill_eal_diverging <- function(...) {
    ggplot2::scale_fill_distiller(palette = "RdBu", ...)
}
