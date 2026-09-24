# theme.R
# To ggplot2-temaer i eal-stil — bygget paa Wilke (theme_dviz_*) og Healy (theme_socviz).
# Begge slaar AV plot.title og plot.subtitle som default (skrives i Quarto-markdown).
# Bruk ggtext::element_markdown() hvis du trenger fargede ord i undertittel.

# 1. Hjelper: trygt font-valg --------------------------------------------

fn_eal_base_family <- function() {
    if (requireNamespace("systemfonts", quietly = TRUE)) {
        fonts <- systemfonts::system_fonts()$family
        if ("Source Sans 3"    %in% fonts) return("Source Sans 3")
        if ("Source Sans Pro"  %in% fonts) return("Source Sans Pro")
    }
    "sans"
}

# 2. Tema 1: minimalt ---------------------------------------------------------
# Hvit bakgrunn, dempet typografi. Ingen grids by default — plot-konstruktoerene
# (eal_line, eal_bar osv.) legger paa rett grid per plottype (jf. Wilke kap. 17).

theme_eal_minimal <- function(base_size = 13) {
    ggplot2::theme_minimal(base_size = base_size, base_family = fn_eal_base_family()) +
    ggplot2::theme(
        plot.title       = ggplot2::element_blank(),
        plot.subtitle    = ggplot2::element_blank(),
        plot.caption     = ggplot2::element_text(colour = "grey50", size = base_size - 3, hjust = 0),
        # Eksplisitt slett ALLE grids — konstruktoeren legger paa add_grid_*() SIST
        # som siste lag. Da har vi forutsigbar grid-kontroll uten override-konflikter.
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        axis.title.x     = ggplot2::element_text(colour = "grey30", size = base_size - 2, hjust = 1),
        axis.title.y     = ggplot2::element_text(colour = "grey30", size = base_size - 2),
        axis.text        = ggplot2::element_text(colour = "grey40", size = base_size - 2),
        axis.line        = ggplot2::element_line(colour = "grey80", linewidth = 0.3),
        axis.ticks       = ggplot2::element_line(colour = "grey80", linewidth = 0.3),
        legend.position  = "top",
        legend.title     = ggplot2::element_blank(),
        legend.text      = ggplot2::element_text(size = base_size - 2),
        strip.text       = ggplot2::element_text(face = "bold", colour = "grey20", size = base_size - 1)
    )
}

# 3. Tema 2: farget ----------------------------------------------------------
# Samme typografi som minimal, men med aksentfargede axis/spines.
# For rapporter og presentasjoner der man vil ha mer visuell vekt.

theme_eal_color <- function(base_size = 13, aksent = "#2c3e50") {
    theme_eal_minimal(base_size = base_size) +
    ggplot2::theme(
        axis.title.x = ggplot2::element_text(colour = aksent, size = base_size - 2, hjust = 1),
        axis.title.y = ggplot2::element_text(colour = aksent, size = base_size - 2),
        axis.text    = ggplot2::element_text(colour = aksent, size = base_size - 2),
        axis.line    = ggplot2::element_line(colour = aksent, linewidth = 0.5),
        axis.ticks   = ggplot2::element_line(colour = aksent, linewidth = 0.5),
        strip.text   = ggplot2::element_text(face = "bold", colour = aksent, size = base_size - 1),
        plot.caption = ggplot2::element_text(colour = "grey40", size = base_size - 3, hjust = 0)
    )
}
