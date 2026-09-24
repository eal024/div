# ggsave.R
# Ferdige ggsave-presets med riktige dimensjoner og dpi.
# Tetter ggsave-gapet i Healys bok (han diskuterer det knapt i kap. 8).
# Format-konvensjoner:
#   - A4 portrait: 16 x 25 cm, 300 dpi (full side, tekst over og under)
#   - A4 landscape: 25 x 16 cm, 300 dpi
#   - Slide 16:9: 25 x 14 cm, 150 dpi (presentasjon, projektor)
#   - Rapport halv: 8 x 6 cm, 300 dpi (innfelt to-spalters)
#   - Rapport hel:  16 x 12 cm, 300 dpi

save_eal_a4_portrait <- function(plot, file, ...) {
    ggplot2::ggsave(file, plot, width = 16, height = 25, units = "cm", dpi = 300, ...)
}

save_eal_a4_landscape <- function(plot, file, ...) {
    ggplot2::ggsave(file, plot, width = 25, height = 16, units = "cm", dpi = 300, ...)
}

save_eal_slide <- function(plot, file, ...) {
    ggplot2::ggsave(file, plot, width = 25, height = 14, units = "cm", dpi = 150, ...)
}

save_eal_rapport <- function(plot, file, bredde = c("halv", "hel"), ...) {
    bredde <- match.arg(bredde)
    w <- if (bredde == "halv")  8 else 16
    h <- if (bredde == "halv")  6 else 12
    ggplot2::ggsave(file, plot, width = w, height = h, units = "cm", dpi = 300, ...)
}
