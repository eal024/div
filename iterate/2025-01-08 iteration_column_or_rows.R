library(tidyverse)

# =============================================================================
# ITERASJON OVER RADER OG KOLONNER: apply(), for-løkke og map_dbl()
# =============================================================================
# Dette skriptet sammenligner tre måter å iterere over rader/kolonner på:
#   1. apply()      — base R, rask og konsis
#   2. for-løkke    — fleksibel, men verbose
#   3. map_dbl()    — purrr-tilnærming
#
# I tillegg benchmarkes ytelsen med microbenchmark.
# =============================================================================

mtcars <- as_tibble(mtcars)


# -----------------------------------------------------------------------------
# 1. apply() — iterasjon over rader eller kolonner
# -----------------------------------------------------------------------------
# apply(X, MARGIN, FUN) anvender FUN langs én dimensjon av X:
#   MARGIN = 1 → kjør FUN for hver RAD    (returnerer én verdi per rad)
#   MARGIN = 2 → kjør FUN for hver KOLONNE (returnerer én verdi per kolonne)

apply(mtcars, MARGIN = 1, FUN = sum)   # sum av alle kolonner per rad
apply(mtcars, MARGIN = 2, FUN = sum)   # sum av alle rader per kolonne


# -----------------------------------------------------------------------------
# 2. for-løkke — manuell iterasjon over rader
# -----------------------------------------------------------------------------
# Tilsvarende som apply(MARGIN=1), men skrevet eksplisitt med en for-løkke.
# Nyttig for å forstå hva apply() gjør bak kulissene, men tregere i praksis.

sum_row_nr <- function(row) {
    s <- 0
    for (i in 1:length(mtcars[row, ])) {
        s <- s + mtcars[row, i][[1]]
    }
    s
}

sum_row_nr(row = 2)   # summer alle verdier i rad nr. 2


# -----------------------------------------------------------------------------
# 3. map_dbl() — purrr-alternativ
# -----------------------------------------------------------------------------
# map_dbl() er mer idiomatisk i tidyverse-kode enn apply().
# Her brukes sum_row_nr() som intern hjelpefunksjon, kalt én gang per rad.

map_dbl(1:nrow(mtcars), \(row) sum_row_nr(row = row))


# -----------------------------------------------------------------------------
# 4. Ytelsessammenligning med microbenchmark
# -----------------------------------------------------------------------------
# microbenchmark kjører hver metode mange ganger og rapporterer
# median, min og max kjøretid i mikrosekunder (µs).
#
# Resultat: apply() er vanligvis klart raskest for enkle operasjoner.
# map_dbl() med egendefinert funksjon er tregere pga. overhead per kall.

microbenchmark::microbenchmark(
    apply              = apply(mtcars, MARGIN = 1, FUN = sum),
    self_made          = map_dbl(1:nrow(mtcars), \(row) sum_row_nr(row = row)),
    alternative_split  = mtcars |> split(1:nrow(mtcars)) |> map_dbl(\(x) sum(unlist(x)))
)
