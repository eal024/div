# =============================================================================
# APPLY-FAMILIEN I BASE R — OVERSIKT
# =============================================================================
# Base R har fire hovedfunksjoner for iterasjon uten eksplisitte løkker.
# Alle tar en liste/vektor/matrise og en funksjon som input.
#
#   apply(X, MARGIN, FUN)           → kjør FUN langs rader (1) eller kolonner (2)
#                                     i en matrise eller data.frame
#
#   lapply(X, FUN)                  → kjør FUN på hvert element i X,
#                                     returnerer alltid en liste
#
#   sapply(X, FUN)                  → som lapply(), men forenkler output
#                                     til vektor/matrise hvis mulig
#
#   mapply(FUN, ...)                → multivariate versjon av sapply():
#                                     kjør FUN over flere vektorer parallelt
#                                     (tilsvarer purrr::pmap())
#
# Kilde: https://www.r-bloggers.com/2025/01/r-for-seo-part-8-apply-methods-in-r/
#
# Se også:
#   - 2023-03-27 apply_family.R  → praktiske eksempler med sapply/lapply/vapply/tapply
#   - 2025-01-08 iteration_column_or_rows.R → apply() vs. map_dbl() med benchmark
# =============================================================================
