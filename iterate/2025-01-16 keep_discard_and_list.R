library(tidyverse)

# =============================================================================
# LISTEHÅNDTERING: keep(), discard(), flatten(), compact() og compose()
# =============================================================================
# Dette skriptet viser hvordan du arbeider med nestede lister i purrr:
#   1. keep() og discard() med navngitte lister
#   2. Ekstraher verdier fra filtrerte lister
#   3. flatten() — fjern ett lag med nesting
#   4. compact() — fjern NULL-elementer
#   5. compose() — kjed flere steg til én funksjon
# =============================================================================


# -----------------------------------------------------------------------------
# Eksempeldata — liste med tweets
# -----------------------------------------------------------------------------

l <- list(
    en  = list(is_retweet = TRUE,  user_id = 1, tweet = "ABC"),
    to  = list(is_retweet = TRUE,  user_id = 2, tweet = "DBC"),
    tre = list(is_retweet = FALSE, user_id = 3, tweet = "ABC")
)


# -----------------------------------------------------------------------------
# 1. keep() med navngitt felt som predikat
# -----------------------------------------------------------------------------
# keep(.x, .p) beholder elementer der .p er TRUE.
# Når .p er en tekststreng, brukes verdien i det navngitte feltet som predikat.
# Dette fungerer fordi keep() kaller map_lgl() internt.

map(l, "is_retweet")    # vis is_retweet-verdien for hvert element
keep(l, "is_retweet")   # behold kun retweets (is_retweet == TRUE)


# -----------------------------------------------------------------------------
# 2. Ekstrahere verdier fra filtrert liste
# -----------------------------------------------------------------------------
# Etter filtrering med keep() kan du hente ut spesifikke felt med map().

# Hent user_id fra alle retweets
keep(l, "is_retweet") |> map("user_id")

# Alternativ med map_lgl() — eksplisitt og like lesbar
l[map_lgl(l, "is_retweet")] |> map("user_id")


# -----------------------------------------------------------------------------
# 3. flatten() — fjern ett lag med nesting
# -----------------------------------------------------------------------------
# flatten() tar en liste av lister og returnerer en flat liste.
# Nyttig når map() produserer ett ekstra listeniå du ikke trenger.

ll <- list(list(a = 1), list(b = 2))
flatten(ll)    # fra liste-av-lister til én flat liste


# -----------------------------------------------------------------------------
# 4. compact() — fjern NULL-elementer
# -----------------------------------------------------------------------------
# compact() er som discard(x, is.null) — fjerner alle NULL-verdier.
# Kombinert med flatten() gir det en ren, flat liste.


# -----------------------------------------------------------------------------
# 5. compose() — kjed et helt pipeline til én funksjon
# -----------------------------------------------------------------------------
# Lange pipelines kan pakkes inn i én funksjon med compose().
# compose() tar funksjonene i revers rekkefølge (sist kjøres først).
#
# Her: hent tweet-tekster → flat ut → fjern NULL → til vektor
#      → frekvenstell → sorter → vis topp

# Eksplisitt pipeline
map(l, "tweet") |> flatten() |> compact() |> unlist() |> table() |> sort() |> tail()

# Samme pipeline som én gjenbrukbar funksjon
fn_tbl <- compose(tail, sort, table, unlist, compact, flatten)

map(l, "tweet") |> fn_tbl()
