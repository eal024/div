library(tidyverse)

# =============================================================================
# FUNKSJONELL VERKTØYKASSE: compose(), partial() og %in%
# =============================================================================
# Dette skriptet viser tre verktøy for å skrive mer konsis funksjonskode:
#   1. compose()  — kjed funksjoner til én ny funksjon (høyre til venstre)
#   2. partial()  — forhåndsutfyll argumenter i en funksjon
#   3. %in%       — sjekk om verdier finnes i en vektor
# =============================================================================

vec <- c(1.5:10.1)


# -----------------------------------------------------------------------------
# 1. compose() — sett sammen to eller flere funksjoner
# -----------------------------------------------------------------------------
# compose(f, g)(x) er det samme som f(g(x)).
# Utføres høyre til venstre: g kjøres først, deretter f.
#
# Her: opphøy i potens (fpower), rund deretter av (fround).

fpower <- function(x, p = 2) x^p
fround <- function(x, d) round(x, digits = d)

# Eksplisitt pipe — leser venstre til høyre
vec |> fpower(p = 3) |> fround(d = 1)

# compose() — lager en ny funksjon som gjør begge steg
power_round <- compose(fround, fpower)   # fround( fpower(x) )
power_round(vec)                         # samme resultat


# -----------------------------------------------------------------------------
# 2. %in% — sjekk om verdier finnes i en annen vektor
# -----------------------------------------------------------------------------
# x %in% y returnerer TRUE for hvert element i x som finnes i y.
# Nyttig for filtrering og betingede oppslag.

4 %in% vec    # TRUE — 4 finnes i vec

y    <- 1:100
test <- 4

test %in% y        # TRUE
y[y %in% test]     # ekstraher elementene i y som matcher test


# -----------------------------------------------------------------------------
# 3. partial() — forhåndsutfyll argumenter
# -----------------------------------------------------------------------------
# partial(.f, ...) lager en ny funksjon der ett eller flere argumenter
# er låst til bestemte verdier. Reduserer gjentakelse i funksjonskall.
#
# Her: lag en avrundingsfunksjon der digits alltid er 0.

round_no_digits <- partial(round, digits = 0)

round_no_digits(c(1.4, 2.7, 9.2))   # runder av til nærmeste heltall
