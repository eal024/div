library(tidyverse)

# =============================================================================
# PURRR: keep(), discard() og nestede lister med map()
# =============================================================================
# Dette skriptet viser tre nyttige purrr-mønstre:
#   1. Generere nestede datasett med map()
#   2. keep() og discard() — filtrer listeelementer med et predikat
#   3. Kombinere map() + keep() for filtrering inni nestede lister
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Generere nestede datasett med map()
# -----------------------------------------------------------------------------
# fn_data() lager et tilfeldig datasett med n observasjoner.
# map(1:12, ...) kaller funksjonen én gang per måned og lagrer
# hvert datasett som et element i en nestet tibble-kolonne.

fn_data <- function(n = sample(10:50, 1)) {
    tibble(
        id     = 1:n,
        age    = sample(18:80, n, replace = TRUE),
        gender = sample(c("M", "F"), n, replace = TRUE, prob = c(0.45, 0.55))
    )
}

# Én rad per måned, med et helt datasett i "data"-kolonnen
df <- tibble(
    mnd  = month(1:12, label = TRUE),
    data = map(1:12, \(x) fn_data())
)

# Navngitt liste — gjør det enklere å referere til måneder ved navn
l_df <- df$data |> set_names(df$mnd)


# -----------------------------------------------------------------------------
# 2. keep() og discard() — filtrer listeelementer med et predikat
# -----------------------------------------------------------------------------
# keep(.x, .p)    → behold kun elementer der .p returnerer TRUE
# discard(.x, .p) → fjern elementer der .p returnerer TRUE
#
# .p kan være en funksjon (is.factor, is.numeric) eller en anonym funksjon.

l <- list(
    a = c(1:4),
    b = letters[1:4] |> as.factor(),
    c = c("bil", "hest") |> as.factor()
)

keep(l,    is.factor)   # returnerer b og c (faktorene)
discard(l, is.factor)   # returnerer a (ikke-faktoren)


# -----------------------------------------------------------------------------
# 3. map() + keep() — filtrer inni nestede lister
# -----------------------------------------------------------------------------
# Ved å kombinere map() og keep() kan du filtrere verdier inne i hvert
# listeelement. Her: behold kun besøksdager med over 500 besøk per gruppe.

random_visit <- function() {
    sample(x = seq(from = 100, to = 1000, by = 10), size = 7, replace = TRUE)
}

# Liste med tre grupper (a, b, c), hver med 7 besøkstall
all_visits <- list(
    a = random_visit(),
    b = random_visit(),
    c = random_visit()
)

# Gi dagnavnene til hvert element
day <- c("mon", "tue", "wed", "thu", "fri", "sat", "sun")
all_visits <- map(all_visits, \(x) set_names(x, day))

# For hver gruppe: behold kun dagene med over 500 besøk
# Resultatet er en liste der antall elementer varierer per gruppe
map(all_visits, \(x) keep(x, function(x) x > 500))
