# konstruktorer.R
# Plot-konstruktoerer i Eiriks stil.
#
# Hvert konstruktoer-kall returnerer et fullt sammensatt plot:
#   ggplot() + geom + scale + theme + add_grid_*
#
# Tema legges paa INNE i konstruktoeren, slik at add_grid_*() alltid blir
# det siste laget. Da kan ingenting overskrive grid-valgene.
#
# Bruker kan velge theme = "minimal" (default) eller "color" via argument.

# Felles tall-format for kontinuerlige akser — norsk konvensjon
eal_y_format <- function() {
    ggplot2::scale_y_continuous(
        labels = scales::label_number(big.mark = " ", decimal.mark = ",")
    )
}

eal_x_format <- function() {
    ggplot2::scale_x_continuous(
        labels = scales::label_number(big.mark = " ", decimal.mark = ",")
    )
}

# Velg tema-funksjon fra string
fn_eal_theme <- function(theme = c("minimal", "color")) {
    switch(match.arg(theme),
        minimal = theme_eal_minimal,
        color   = theme_eal_color
    )
}

# 1. Linje / tidsserie ---------------------------------------------------

eal_line <- function(data, x, y, color = NULL, palette = "okabe_ito",
                     theme = c("minimal", "color")) {
    theme_fn <- fn_eal_theme(theme)
    ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})) +
        ggplot2::geom_line(linewidth = 0.8) +
        eal_y_format() +
        scale_color_eal_qualitative(palette = palette) +
        theme_fn() +
        add_grid_h()
}

# 2. Bar -----------------------------------------------------------------
# Vertikal bar: kategorisk x, numerisk y. Horisontale grids (referanse for y-verdi).
# Horisontal bar: vi bytter aes direkte (ingen coord_flip — det forvirrer grid-mapping).
# Vertikale grids (referanse for x-verdi).

eal_bar <- function(data, x, y, fill = NULL, orientation = c("v", "h"),
                    palette = "okabe_ito",
                    theme = c("minimal", "color")) {
    orientation <- match.arg(orientation)
    theme_fn    <- fn_eal_theme(theme)

    if (orientation == "h") {
        # Horisontal: x-arg blir vertikal kategori, y-arg blir horisontal verdi
        ggplot2::ggplot(data,
                        ggplot2::aes(x = {{ y }}, y = {{ x }}, fill = {{ fill }})) +
            ggplot2::geom_col() +
            ggplot2::scale_x_continuous(
                expand = ggplot2::expansion(mult = c(0, 0.05)),
                labels = scales::label_number(big.mark = " ", decimal.mark = ",")
            ) +
            scale_fill_eal_qualitative(palette = palette) +
            theme_fn() +
            add_grid_v()
    } else {
        ggplot2::ggplot(data,
                        ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})) +
            ggplot2::geom_col() +
            ggplot2::scale_y_continuous(
                expand = ggplot2::expansion(mult = c(0, 0.05)),
                labels = scales::label_number(big.mark = " ", decimal.mark = ",")
            ) +
            scale_fill_eal_qualitative(palette = palette) +
            theme_fn() +
            add_grid_h()
    }
}

# 3. Scatter -------------------------------------------------------------
# Endret per brukers preferanse: kun horisontale grids (ikke baade).
# Default: ingen smoothing. Slaa paa med smooth = TRUE. Konfidensbaand
# kun naar smooth_se = TRUE (Wilke kap. 16 — usikkerhet skal forklares).

eal_scatter <- function(data, x, y, color = NULL,
                        smooth = FALSE, smooth_se = FALSE,
                        palette = "okabe_ito",
                        theme = c("minimal", "color")) {
    theme_fn <- fn_eal_theme(theme)
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})) +
        ggplot2::geom_point(size = 2, alpha = 0.8) +
        scale_color_eal_qualitative(palette = palette)
    if (smooth) {
        p <- p + ggplot2::geom_smooth(method = "loess", se = smooth_se,
                                       linewidth = 0.8, formula = y ~ x)
    }
    p + theme_fn() + add_grid_h()
}

# 4. Distribusjon --------------------------------------------------------

eal_distribution <- function(data, x, type = c("histogram", "density", "freqpoly"),
                              fill = NULL, palette = "okabe_ito", bins = 30,
                              theme = c("minimal", "color")) {
    type     <- match.arg(type)
    theme_fn <- fn_eal_theme(theme)
    p <- ggplot2::ggplot(data,
                         ggplot2::aes(x = {{ x }}, fill = {{ fill }}, color = {{ fill }}))
    p <- p + switch(type,
        histogram = ggplot2::geom_histogram(bins = bins, alpha = 0.6, position = "identity"),
        density   = ggplot2::geom_density(alpha = 0.4),
        freqpoly  = ggplot2::geom_freqpoly(bins = bins, linewidth = 0.8)
    )
    p +
        scale_fill_eal_qualitative(palette = palette) +
        scale_color_eal_qualitative(palette = palette) +
        theme_fn() +
        add_grid_h()
}

# 5. Paired (x = y-relasjon) ---------------------------------------------

eal_paired <- function(data, x, y, color = NULL, palette = "okabe_ito",
                       theme = c("minimal", "color")) {
    theme_fn <- fn_eal_theme(theme)
    ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})) +
        add_diagonal() +
        ggplot2::geom_point(size = 2, alpha = 0.8) +
        scale_color_eal_qualitative(palette = palette) +
        ggplot2::coord_equal() +
        theme_fn()
}
