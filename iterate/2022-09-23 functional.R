library(tidyverse)

# =============================================================================
# FUNKSJONELL PROGRAMMERING I R: map, walk, imap, pmap, reduce, accumulate
# =============================================================================
# Dette skriptet dekker kjernekonseptene i funksjonell programmering med purrr:
#   1.  Høyere-ordens funksjoner   — funksjoner som tar funksjoner som input
#   2.  map() og typede varianter  — map_int, map_dbl, map_chr, map_lgl
#   3.  vapply()                   — base R-alternativ med typesjekk
#   4.  Anonyme funksjoner (~)     — lambda-syntaks i purrr
#   5.  Ekstrahere fra lister      — map(x, "navn") og map(x, indeks)
#   6.  Ekstra argumenter          — sende args til .f via ~
#   7.  Subgruppe-modellering      — lm() per gruppe med map()
#   8.  modify() / modify_if()     — modifiser og behold struktur
#   9.  walk() / walk2()           — iterasjon med sideeffekter
#   10. imap()                     — iterasjon med indeks/navn
#   11. pmap()                     — iterasjon over flere lister
#   12. reduce() / accumulate()    — aggregering og mellomresultater
#   13. Predikatfunksjoner         — some, every, none, detect
#   14. Funksjons-fabrikker        — funksjoner som lager funksjoner
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Høyere-ordens funksjoner — funksjoner som tar funksjoner som input
# -----------------------------------------------------------------------------
# En funksjon kan ta en annen funksjon (f) som argument.
# Her tar `ran()` en funksjon og bruker den på 10 tilfeldige tall.

ran <- function(f) f(runif(10))

ran(sd)   # standardavvik av 10 tilfeldige tall
ran(sum)  # summen av 10 tilfeldige tall


# -----------------------------------------------------------------------------
# 2. map() — kall en funksjon for hvert element i en vektor/liste
# -----------------------------------------------------------------------------
# map(.x, .f) returnerer alltid en liste.
# Bruk typede varianter for å returnere en spesifikk vektortype:
#   map_int()  → heltallsvektor
#   map_dbl()  → desimalvektor
#   map_chr()  → karaktervektor
#   map_lgl()  → logisk vektor

map(1:3, function(x) x * 2)          # liste med [2, 4, 6]

n_unique <- function(x) length(unique(x))

map_int(mtcars, n_unique)            # antall unike verdier per kolonne
map_dbl(mtcars, mean)                # gjennomsnitt per kolonne
map_chr(mtcars, mean)                # gjennomsnitt som tekst
map_lgl(mtcars, is.double)           # er kolonnen av type double?


# -----------------------------------------------------------------------------
# 3. vapply() — base R med eksplisitt returtype
# -----------------------------------------------------------------------------
# vapply(X, FUN, FUN.VALUE) er som sapply(), men sikrere fordi du
# oppgir forventet returtype med FUN.VALUE. Krasjer heller enn å returnere
# feil type stille.

vapply(c(1:3), function(x) x * 2, FUN.VALUE = double(1))


# -----------------------------------------------------------------------------
# 4. Anonyme funksjoner — tilde-syntaks (~) i purrr
# -----------------------------------------------------------------------------
# I stedet for function(x) ... kan du bruke ~... der .x er argumentet.
# as_mapper() viser hva purrr gjør bak kulissene.

as_mapper(~length(unique(.x)))       # konverterer ~ til en funksjon

x <- map(1:3, ~runif(2))             # generer 2 tilfeldige tall 3 ganger
x


# -----------------------------------------------------------------------------
# 5. Ekstrahere fra nestede lister med map()
# -----------------------------------------------------------------------------
# map(x, 1)      → hent element nr. 1 fra hvert listeelement
# map(x, "navn") → hent navngitt element fra hvert listeelement
# map(x, list("y", 2)) → hent nestede elementer (y[[2]])

x <- list(
    list(-1, x = 1, y = c(2),    z = "a"),
    list(-2, x = 4, y = c(5, 6), z = "B"),
    list( 1, x = 1, y = 1:10)
)

map(x, 1)           # første element fra hvert listeelement
map(x, "x")         # element med navn "x"
map(x, "y")         # element med navn "y"
map(x, "z")         # element med navn "z"
map(x, list("y", 2))# nestede: y[[2]] fra hvert element


# -----------------------------------------------------------------------------
# 6. Ekstra argumenter til .f via ~ eller direkte
# -----------------------------------------------------------------------------
# Bruk ~round(mean(x), digits = .x) for å sende ekstra verdier inn i .f.
# Alternativt: skriv ut hele funksjonen eksplisitt for bedre lesbarhet.

x <- rcauchy(10)

trim <- c(0, 1, 2, 3)

# Tilde-syntaks
map(trim, ~round(mean(x), digits = .x))

# Eksplisitt funksjon — tydeligere og enklere å feilsøke
map(trim, function(trim) round(x, digits = trim))


# -----------------------------------------------------------------------------
# 7. Subgruppe-modellering med map()
# -----------------------------------------------------------------------------
# Klassisk purrr-mønster: del data i grupper → tilpass modell → ekstraher koef.

by_cyl <- split(mtcars, mtcars$cyl)   # liste med én df per sylindertall

# Hent stigningstallet (koeffisient nr. 2) for wt i mpg ~ wt per gruppe
map(by_cyl, function(x) lm(mpg ~ wt, data = x)) |>
    map(coef) |>
    map_dbl(2)

# Hent estimate og std.error i en ryddig tibble
coef_tbl <- map(by_cyl, function(x) lm(mpg ~ wt, data = x)) |>
    map(summary) |>
    map(function(x) coef(x))

tibble(
    by_cyl   = names(by_cyl),
    estimate = map_dbl(coef_tbl, function(x) x[2, "Estimate"]),
    st.error = map_dbl(coef_tbl, function(x) x[2, "Std. Error"])
)


# -----------------------------------------------------------------------------
# 8. modify() og modify_if() — modifiser og behold struktur
# -----------------------------------------------------------------------------
# modify() er som map(), men returnerer samme objekttype som input.
# modify_if() anvender .f kun på elementer der predikatet er TRUE.

df <- data.frame(x = 1:4, y = 5:8)

map(df, ~.x * 2)              # returnerer liste
modify(df, ~.x * 2)           # returnerer data.frame

df$z <- letters[1:4]

modify_if(df, ~is.numeric(.x), ~.x * 2)  # dobler kun numeriske kolonner


# -----------------------------------------------------------------------------
# 9. walk() og walk2() — iterasjon med sideeffekter
# -----------------------------------------------------------------------------
# walk() er som map(), men brukes når du bare vil ha sideeffekter
# (print, lagre til disk, sende melding) og ikke trenger returverdien.
# walk2() itererer over to lister parallelt.

text_message <- function(name) {
    cat("Hei ", name, "!\n", sep = "")
}

liste_navn <- c("Eirik", "Trym", "Ove")

map(liste_navn, function(x) text_message(x))   # returnerer liste (uønsket)
walk(liste_navn, function(x) text_message(x))  # returnerer ingenting — bedre

# Lagre delsett av mtcars til separate CSV-filer
cyls  <- split(mtcars, mtcars$cyl)
temp  <- tempdir()
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)                  # skriver én fil per gruppe


# -----------------------------------------------------------------------------
# 10. imap() — iterasjon med indeks eller navn
# -----------------------------------------------------------------------------
# imap(.x, .f) gir .f to argumenter: .x (verdien) og .y (navn eller indeks).
# Nyttig når du trenger å referere til kolonnenavn eller listeposisjon.

imap_chr(iris, ~paste0("Første verdi av: ", .y, " er ", .x[[1]]))

a <- list(
    x    = c(1, 2, 3),
    y    = c("a", "b", "c"),
    navn = c("Eirik", "Trym", "ove")
)

imap(a, ~.x[[2]])   # hent andre element fra hvert listeelement, med navn

x <- map(1:6, ~sample(1000, 10))
imap_chr(x, ~glue::glue("Høyeste verdi av element {.y} er {max(.x)}"))


# -----------------------------------------------------------------------------
# 11. pmap() — iterasjon over flere lister/kolonner parallelt
# -----------------------------------------------------------------------------
# pmap(.l, .f) sender hvert sett med verdier fra listen som navngitte
# argumenter til .f. Fungerer godt med en tibble som parameter-tabell.

params <- tibble::tribble(
    ~n, ~min, ~max,
    1L,    0,    1,
    2L,   10,  100,
    3L,  100, 1000
)

set.seed(123)

pmap(params, function(n, min, max) runif(n = n, min = min, max = max))

# Kortform: hvis argumentnavnene matcher, kan du sende funksjonen direkte
pmap(params, runif)


# -----------------------------------------------------------------------------
# 12. reduce() og accumulate() — aggregering langs en vektor
# -----------------------------------------------------------------------------
# reduce(.x, .f) anvender .f kumulativt og returnerer ett sluttresultat.
#   reduce(1:3, f) = f(f(1, 2), 3)
#
# accumulate(.x, .f) gjør det samme, men returnerer ALLE mellomresultater.
# Nyttig for å forstå hva reduce gjør, eller for trinnvise beregninger.

reduce(1:3, `+`)        # 1 + 2 + 3 = 6
reduce(1:3, sum)        # samme resultat

x <- c(4, 3, 10)
accumulate(x, sum)      # [4, 7, 17] — viser hvert steg

# .init setter startverdi
reduce(x, sum, .init = 0)
reduce(x, sum, .init = 10)   # starter på 10: 10+4+3+10 = 27

# Praktisk eksempel: finn elementer som finnes i ALLE vektorer (intersect)
l <- map(1:3, ~sample(1:10, replace = TRUE))

reduce(l, intersect)    # felles elementer i alle tre
reduce(l, union)        # elementer som finnes i minst én

accumulate(l, intersect) # viser prosessen trinn for trinn


# -----------------------------------------------------------------------------
# 13. Predikatfunksjoner — some, every, none, detect
# -----------------------------------------------------------------------------
# some(.x, .p)         → TRUE hvis minst ett element oppfyller .p
# every(.x, .p)        → TRUE hvis alle elementer oppfyller .p
# none(.x, .p)         → TRUE hvis ingen elementer oppfyller .p
# detect(.x, .p)       → returnerer første element som oppfyller .p
# detect_index(.x, .p) → returnerer indeksen til første match

ex <- list("1!", c(1:10))

some(ex,  is.numeric)    # TRUE  — minst ett element er numerisk
every(ex, is.numeric)    # FALSE — ikke alle er numeriske
none(ex,  is.numeric)    # FALSE — det finnes minst ett numerisk element

map(ex, ~detect(.x,       is.numeric))  # første numeriske verdi
map(ex, ~detect_index(.x, is.numeric))  # indeks til første numeriske verdi

keep(c(11:20), is.numeric)              # behold kun numeriske verdier


# -----------------------------------------------------------------------------
# 14. Funksjons-fabrikker — funksjoner som lager funksjoner
# -----------------------------------------------------------------------------
# En funksjons-fabrikk er en funksjon som returnerer en ny funksjon.
# Det ytre funksjonsanropet setter parametere (f.eks. eksponent),
# og den returnerte funksjonen bruker dem.

power1 <- function(exp) {
    function(x) x^exp
}

square <- power1(2)   # lager en "kvadrat-funksjon"
cube   <- power1(3)   # lager en "kube-funksjon"

square(3)  # 3^2 = 9
cube(3)    # 3^3 = 27

# force() låser verdien av exp ved opprettelse, unngår lazy eval-problemer
power2 <- function(exp) {
    force(exp)
    function(x) x^exp
}

# Teller-fabrikk: hvert kall øker en intern teller med <<-
new_counter <- function() {
    i <- 0
    function() {
        i <<- i + 1   # <<- oppdaterer i i det ytre miljøet
        i
    }
}

en <- new_counter()
to <- new_counter()   # uavhengig teller

en()   # 1
en()   # 2
to()   # 1  — sin egen teller
