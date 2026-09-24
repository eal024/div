# grids.R
# Grid-hjelpere etter Wilke kap. 17 ("Balance the data and the context"):
# - scatter:        grids paa begge akser (lette)
# - line/tidsserie: kun horisontale ved hovedticks
# - staaende bar:   kun horisontale (vinkelrett paa bar-retning)
# - liggende bar:   kun vertikale
# - paired data:    x = y-linje, ingen grid

add_grid_h <- function() {
    ggplot2::theme(
        panel.grid.major.y = ggplot2::element_line(colour = "grey92", linewidth = 0.25),
        panel.grid.minor.y = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_blank(),
        panel.grid.minor.x = ggplot2::element_blank()
    )
}

add_grid_v <- function() {
    ggplot2::theme(
        panel.grid.major.x = ggplot2::element_line(colour = "grey92", linewidth = 0.25),
        panel.grid.minor.x = ggplot2::element_blank(),
        panel.grid.major.y = ggplot2::element_blank(),
        panel.grid.minor.y = ggplot2::element_blank()
    )
}

add_grid_both <- function() {
    ggplot2::theme(
        panel.grid.major = ggplot2::element_line(colour = "grey92", linewidth = 0.25),
        panel.grid.minor = ggplot2::element_blank()
    )
}

# Diagonal x = y-linje for paired data
add_diagonal <- function(slope = 1, intercept = 0, color = "grey60") {
    ggplot2::geom_abline(
        slope     = slope,
        intercept = intercept,
        colour    = color,
        linewidth = 0.4,
        linetype  = "dashed"
    )
}
