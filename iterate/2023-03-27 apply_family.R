library(tidyverse)

# =============================================================================
# APPLY-FAMILIEN I BASE R
# =============================================================================
# Base R har en familie av funksjoner for iterasjon uten løkker.
# De tilsvarer purrr::map() og varianter, men er innebygd i R.
#
#   sapply(X, FUN)              → forenklet output (vektor/matrise hvis mulig)
#   lapply(X, FUN)              → returnerer alltid liste
#   vapply(X, FUN, FUN.VALUE)   → som sapply, men med eksplisitt returtype
#   tapply(X, INDEX, FUN)       → gruppert aggregering (som group_by + summarise)
#
# purrr-ekvivalenter er vist der det er relevant.
# =============================================================================


# -----------------------------------------------------------------------------
# Eksempeldata
# -----------------------------------------------------------------------------

df <- data.frame(a = 1, b = 2, c = "a", d = "b", e = 4)
df


# -----------------------------------------------------------------------------
# sapply() — finn hvilke kolonner som er numeriske
# -----------------------------------------------------------------------------
# sapply(X, FUN) anvender FUN på hvert element i X og forenkler resultatet
# til en vektor eller matrise hvis mulig. Returnerer en navngitt logisk
# vektor her.

sapply(df, is.numeric)

# purrr-ekvivalent — map_lgl() er mer eksplisitt og forutsigbar
map_lgl(df, is.numeric)


# -----------------------------------------------------------------------------
# lapply() — transformer numeriske kolonner
# -----------------------------------------------------------------------------
# lapply(X, FUN) returnerer alltid en liste — tryggere enn sapply() når
# du ikke vet hva returtypen blir.
#
# Her: identifiserer numeriske kolonner med sapply(), så dobler verdiene
# med lapply() og tilordner resultatet tilbake til de samme kolonnene.

num_cols <- sapply(df, is.numeric)

df[, num_cols] <- lapply(df[, num_cols], \(x) x * 2)
df


# -----------------------------------------------------------------------------
# vapply() — strengere versjon av sapply() med typesjekk
# -----------------------------------------------------------------------------
# vapply(X, FUN, FUN.VALUE) krever at du oppgir forventet returtype
# via FUN.VALUE. Krasjer med en klar feilmelding hvis typen ikke stemmer.
# Anbefalt i produksjonskode der forutsigbarhet er viktig.
#
# FUN.VALUE = logical(1) betyr: forvent én logisk verdi per element.

vapply(df, function(x) is.numeric(x), FUN.VALUE = logical(1))


# -----------------------------------------------------------------------------
# tapply() — gruppert aggregering
# -----------------------------------------------------------------------------
# tapply(X, INDEX, FUN) deler X inn i grupper definert av INDEX,
# og anvender FUN på hver gruppe. Tilsvarer group_by() + summarise() i dplyr.
#
# Her: beregner gjennomsnittlig pris per kutt-kategori i diamonds.

# dplyr-tilnærming (lesbar og ryddig)
diamonds |>
    group_by(cut) |>
    summarise(price = mean(price))

# tapply-tilnærming (base R, kompakt)
stat <- tapply(diamonds$price, diamonds$cut, function(x) mean(x))

# Konverter til tibble for videre bruk
tibble(name = names(stat), stat)
