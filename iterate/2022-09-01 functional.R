library(tidyverse)

# =============================================================================
# ITERASJON I R: pwalk() og for-løkke
# =============================================================================
# Dette skriptet viser to måter å iterere over verdier i R:
#   1. pwalk() fra purrr - funksjonell tilnærming
#   2. for-løkke         - klassisk imperativ tilnærming
# =============================================================================


# -----------------------------------------------------------------------------
# 1. pwalk() — iterasjon over flere lister parallelt
# -----------------------------------------------------------------------------
# pwalk() er en "walk"-variant av purrr::pmap().
# Den brukes når du vil iterere over FLERE vektorer/lister samtidig,
# og kun er ute etter sideeffekter (f.eks. print, lagre fil),
# ikke en returverdi.
#
# Syntaks:
#   pwalk(.l = list(...), .f = function(...) { ... })
#
#   .l  : en liste med navngitte vektorer — ett element per iterasjon
#   .f  : en funksjon der argumentnavnene matcher navnene i listen
#
# Her kjøres 3 iterasjoner:
#   i=1: en=1, to=11  → 1 * 11 = 11
#   i=2: en=2, to=12  → 2 * 12 = 24
#   i=3: en=3, to=13  → 3 * 13 = 39

pwalk(
    .l = list(en = 1:3, to = 11:13),
    .f = function(en, to) {
        x <- en * to
        print(paste0("Produktet av ", en, " og ", to, " er: ", x))
    }
)

# Merk: pwalk() returnerer .l usynlig (ikke resultatet av .f).
# Bruk pmap() hvis du trenger å samle returverdiene.


# -----------------------------------------------------------------------------
# 2. for-løkke — klassisk iterasjon
# -----------------------------------------------------------------------------
# En for-løkke går gjennom hvert element i en sekvens én etter én.
#
# Syntaks:
#   for (variabel in sekvens) { ... }
#
# Her kjøres løkken 3 ganger med i = 1, 2, 3.

for (i in 1:3) {
    print(i)
}

# Merk: for-løkker er enkle og lesbare, men tregere enn vektoriserte
# alternativer ved store datasett. Foretrekk map()/apply()-familien
# der ytelse er viktig.
