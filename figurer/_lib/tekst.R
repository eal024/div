# tekst.R
# Hjelpere for tekst-elementer i figurer.

# Bygg HTML-streng for undertittel med fargede ord.
# Brukes sammen med ggtext::element_markdown() i theme().
#
# Eksempel:
#   subtitle <- subtitle_med_farger(
#       "Andelen nedsatt arbeidsevne har vokst, mens arbeidssoekere holder seg flat.",
#       farger = list("nedsatt arbeidsevne" = "#1a6b4a",
#                     "arbeidssoekere"      = "#2c3e50")
#   )
#   ggplot(...) +
#       labs(subtitle = subtitle) +
#       theme_eal_minimal() +
#       theme(plot.subtitle = ggtext::element_markdown())

subtitle_med_farger <- function(tekst, farger = list()) {
    for (ord in names(farger)) {
        farge       <- farger[[ord]]
        erstatning  <- sprintf("<span style='color:%s'><b>%s</b></span>", farge, ord)
        tekst       <- gsub(ord, erstatning, tekst, fixed = TRUE)
    }
    tekst
}

# Y-aksetittel plassert oeverst i plot-arealet (innenfor tallene).
# Frigjoer venstre marg, og tittelen staar over det oeverste tall paa y-aksen.
# Bruk istedenfor labs(y = "...") naar du vil ha en kompakt layout.
#
# Eksempel:
#   eal_line(data, x = maaned, y = antall) +
#       eal_y_title("Antall mottakere")

eal_y_title <- function(label, size = 3.6, colour = "grey30") {
    list(
        ggplot2::labs(y = NULL),
        ggplot2::theme(plot.margin = ggplot2::margin(t = 25, r = 8, b = 5, l = 5)),
        ggplot2::annotate("text", x = -Inf, y = Inf, label = label,
                          hjust = -0.05, vjust = -0.7,
                          size = size, colour = colour),
        ggplot2::coord_cartesian(clip = "off")
    )
}

# Standardisert kilde-caption.
# Eksempel: kilde_caption("NAV", "2026-05-01") -> "Kilde: NAV, mai 2026"

kilde_caption <- function(kilde, dato = NULL) {
    if (is.null(dato)) {
        paste0("Kilde: ", kilde)
    } else {
        # Bruk maaned + aar paa norsk
        maaneder <- c("januar", "februar", "mars", "april", "mai", "juni",
                      "juli", "august", "september", "oktober", "november", "desember")
        d        <- as.Date(dato)
        paste0("Kilde: ", kilde, ", ", maaneder[as.integer(format(d, "%m"))], " ", format(d, "%Y"))
    }
}
