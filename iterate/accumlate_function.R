library(purrr)
library(ggplot2)

# =============================================================================
# accumulate() — MELLOMRESULTATER OG AVANSERT BRUK
# =============================================================================
# accumulate(.x, .f) anvender .f kumulativt og returnerer alle mellomresultater.
# Tilsvarer reduce(), men beholder hvert steg — ikke bare sluttresultatet.
#
# Dette skriptet dekker:
#   1. Grunnleggende bruk — tall og tekst
#   2. .dir = "backward"  — iterer bakover
#   3. done()             — avslutt tidlig basert på betingelse
#   4. Random walk        — simuler tilfeldige bevegelser med drift
#   5. Pascals trekant    — klassisk matematisk eksempel
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Grunnleggende bruk — kumulativ sum og paste
# -----------------------------------------------------------------------------
# accumulate() med `+` gir kumulative summer — tilsvarer cumsum().

1:3 |> accumulate(`+`)     # [1, 3, 6]
c(1, 2, 3) |> cumsum()     # [1, 3, 6] — identisk resultat

# Kumulativ sammenkobling av bokstaver
letters[1:4] |> accumulate(paste)   # "a", "a b", "a b c", "a b c d"

# Egendefinert separatortegn
paste_alt  <- function(acc, nxt) paste(acc, nxt, sep = ".")
paste_alt2 <- function(acc, nxt) paste(nxt, acc, sep = ".")

letters[1:4] |> accumulate(paste_alt)                      # "a", "a.b", "a.b.c", ...
letters[1:4] |> accumulate(paste_alt, .dir = "backward")   # starter fra siste element


# -----------------------------------------------------------------------------
# 2. .dir = "backward" — iterer fra høyre mot venstre
# -----------------------------------------------------------------------------
# Med .dir = "backward" starter accumulate() fra det siste elementet
# og arbeider seg bakover. Nyttig for høyreassosierte operasjoner.

letters[1:4] |> accumulate(paste_alt2, .dir = "backward")


# -----------------------------------------------------------------------------
# 3. done() — avslutt iterasjonen tidlig
# -----------------------------------------------------------------------------
# done() sender et signal til accumulate() om å stoppe iterasjonen.
# Nyttig når du vil avbryte basert på en betingelse i akkumulatoren.

# Stopp når resultatet er lengre enn 6 tegn
paste3 <- function(out, input, sep = ".") {
    if (nchar(out) > 6) return(done(out))
    paste(out, input, sep = sep)
}

letters |> accumulate(paste3)   # stopper etter "a.b.c.d" (8 tegn)

# Stopp ved et spesifikt input-element
paste4 <- function(out, input, sep = ".") {
    if (input == "f") return(done())
    paste(out, input, sep = sep)
}

letters |> accumulate(paste4)   # stopper når input er "f"


# -----------------------------------------------------------------------------
# 4. Random walk med drift
# -----------------------------------------------------------------------------
# accumulate() er godt egnet til å simulere tidsserieprosesser der
# hvert steg avhenger av forrige verdi.
#
# Formel: x_t = drift + x_{t-1} + ε_t   (ε ~ N(0,1))

r_number <- rnorm(10)
r_number |> accumulate(\(acc, nxt) .05 + acc + nxt)

# Simuler 5 random walks med 100 steg
list_df <- map(1:5, \(i) rnorm(100)) |>
    set_names(paste0("sim", 1:5)) |>
    map(\(l) accumulate(l, \(acc, nxt) .05 + acc + nxt)) |>
    map(\(x) tibble(value = x, step = 1:100))

bind_rows(list_df, .id = "simulation") |>
    ggplot(aes(x = step, y = value)) +
    geom_line(aes(color = simulation)) +
    ggtitle("Simulations of a random walk with drift")


# -----------------------------------------------------------------------------
# 5. Pascals trekant
# -----------------------------------------------------------------------------
# Hvert rad i Pascals trekant er summen av to naboelementer fra raden over.
# Dette kan uttrykkes elegant med accumulate() og vektoraddisjon:
#   neste rad = c(0, forrige) + c(forrige, 0)

row <- c(1, 3, 3, 1)
c(0, row) + c(row, 0)   # [1, 4, 6, 4, 1] — neste rad

# Generer de 6 første radene
accumulate(1:6, ~ c(0, .) + c(., 0), .init = 1)
