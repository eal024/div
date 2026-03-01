library(tidyverse)

# =============================================================================
# RECAP: accumulate(), reduce() og compose() med flere funksjoner
# =============================================================================
# Dette skriptet oppsummerer og kombinerer sentrale funksjonelle konsepter:
#   1. accumulate() vs reduce() vs cumsum()  — kumulativ aggregering
#   2. compose()                             — kjed to funksjoner
#   3. app_fun()                             — anvend flere funksjoner på én verdi
# =============================================================================


# -----------------------------------------------------------------------------
# 1. accumulate() vs reduce() vs cumsum()
# -----------------------------------------------------------------------------
# accumulate(.x, .f) — returnerer ALLE mellomresultater (som cumsum)
# reduce(.x, .f)     — returnerer kun SLUTTRESULTATET
# cumsum()           — base R-ekvivalent for kumulativ sum

numbers <- c(1:4) |> as.list()

accumulate(numbers, `+`)          # [1, 3, 6, 10] — alle steg
reduce(numbers, `+`)              # [10]           — kun slutt
cumsum(numbers)                   # [1, 3, 6, 10] — base R-ekvivalent


# -----------------------------------------------------------------------------
# 2. compose() — kombiner to funksjoner til én
# -----------------------------------------------------------------------------
# compose(f, g)(x) = f(g(x))
# Utføres høyre til venstre: g kjøres først, deretter f.
#
# Her: square(x) = x^2, add(x) = x + 1
# add_and_sq(x) = add(square(x)) = x^2 + 1

add    <- function(x) x + 1
square <- function(x) x^2

add_and_sq <- compose(add, square)    # square kjøres først, så add

map_dbl(numbers, \(x) add_and_sq(x)) # [2, 5, 10, 17]


# -----------------------------------------------------------------------------
# 3. app_fun() — anvend flere funksjoner på én og samme verdi
# -----------------------------------------------------------------------------
# Egendefinert hjelpefunksjon som tar en verdi (x) og et sett funksjoner (...),
# og returnerer en navngitt vektor med resultatet av hver funksjon.
#
# Nyttig for å beregne flere statistikker på én gang.

app_fun <- function(x, ...) purrr::map_dbl(list(...), \(f) f(x))

app_fun(1:4, mean, median, sd)   # [2.5, 2.5, 1.29]

# Kombinert med split() og map(): beregn statistikk per gruppe
test <- split(mtcars, mtcars$carb)

map(
    map(test, 1),     # hent første kolonne (mpg) per carb-gruppe
    \(x) app_fun(x, mean, median, sd) |> set_names(c("mean", "median", "sd"))
)
