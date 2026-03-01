library(tidyverse)

# =============================================================================
# PREDIKATFUNKSJONER OG FEILHÅNDTERING: every(), some(), safely()
# =============================================================================
# Dette skriptet dekker:
#   1. every() og some() — sjekk om betingelser gjelder for listeelementer
#   2. Manuell tilnærming vs. predikatfunksjoner
#   3. safely() — håndter feil i map() uten at kjøringen stopper
# =============================================================================


# -----------------------------------------------------------------------------
# Eksempeldata — besøkstall per dag for tre grupper
# -----------------------------------------------------------------------------

random_visit <- function() {
    sample(x = seq(from = 100, to = 1000, by = 10), size = 7, replace = TRUE)
}

all_visits <- list(
    a = random_visit(),
    b = random_visit(),
    c = random_visit()
)

day <- c("mon", "tue", "wed", "thu", "fri", "sat", "sun")

all_visits <- map(all_visits, \(x) set_names(x, day))


# -----------------------------------------------------------------------------
# 1. every() — gjelder betingelsen for ALLE elementer i lista?
# -----------------------------------------------------------------------------
# every(.x, .p) returnerer TRUE hvis .p er TRUE for hvert element i .x.
#
# Manuell tilnærming: sammenlign sum(betingelse) med lengden av vektoren.
# every() er kortere og tydeligere.

# Manuell versjon
map(
    map(all_visits, \(x) x > 200),
    \(x) sum(x) == length(x)
)

# every() — er alle besøksdager over 200?
map(all_visits, \(x) every(x, \(x) x > 200))


# -----------------------------------------------------------------------------
# 2. some() — gjelder betingelsen for MINST ETT element?
# -----------------------------------------------------------------------------
# some(.x, .p) returnerer TRUE hvis .p er TRUE for minst ett element i .x.

# Manuell versjon
map(
    map(all_visits, \(x) x > 200),
    \(x) sum(x) > 0
)

# some() — er minst én besøksdag over 200?
map(all_visits, \(x) some(x, \(x) x > 200))


# -----------------------------------------------------------------------------
# 3. safely() — feilhåndtering i map()
# -----------------------------------------------------------------------------
# Normalt stopper map() hvis .f kaster en feil for ett element.
# safely(.f) wrapper .f slik at den alltid returnerer en liste med:
#   $result → resultatet hvis vellykket, ellers NULL
#   $error  → feilmeldingen hvis noe gikk galt, ellers NULL
#
# Nyttig når du itererer over data der noen elementer kan feile
# (f.eks. log() av negativt tall eller tekst).

map(list(1, 2, "a"), log)              # krasjer ved "a"
map(list(1, 2, "a"), safely(log))      # returnerer result/error per element

# Ekstraher kun vellykkede resultater
map(list(1, 2, 3, "a"), safely(\(x) log(x))) |>
    map("result")
