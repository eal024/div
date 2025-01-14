# Laster inn nødvendige biblioteker
library(tidyverse)  # For datahåndtering og funksjoner som `map` og `filter`
library(broom)      # For å konvertere modellobjekter til dataframes

# Konverterer iris-datasettet til en tibble for enklere databehandling
df <- as_tibble(iris)

# Kjører en enkel lineær regresjonsmodell for å teste sammenhengen mellom Sepal.Length og Species
# Bruker tidy() for å hente ut resultatene og filter() for å bare beholde signifikante resultater
df |> 
  lm(formula = Sepal.Length ~ Species) |> 
  tidy() |> 
  filter(p.value < 0.05)

# Gjentar det samme for Sepal.Width som avhengig variabel
df |> 
  lm(formula = Sepal.Width ~ Species) |> 
  tidy() |> 
  filter(p.value < 0.05)

# Lager en liste over formler for modellene som skal testes
formulas <- list(
  Sepal.Length ~ Species,
  Sepal.Width ~ Species
)

# Definerer en sammensatt funksjon med compose for å:
# 1. Tilpasse lineær modell med lm
# 2. Hente ut oppsummeringsresultater med tidy
# 3. Filtrere resultatene for å bare vise signifikante p-verdier
tidy_iris_lm <- compose(
  as_mapper(~filter(.x, p.value < 0.05)),  # Behold kun signifikante resultater
  tidy,                                   # Konverter modellresultater til tabellformat
  partial(lm, data = df, na.action = na.fail)  # Tilpass lineær modell
)

# Bruker map for å anvende funksjonen på hver formel i listen
formulas |> map(tidy_iris_lm)

# Alternativ metode: Lager en funksjon som gjør det samme som compose-strukturen over
fn_tidy_lm <- function(x) { 
  lm(formula = x, data = df, na.action = na.fail) |>  # Tilpasser lineær modell
    tidy() |>                                        # Konverterer modellresultater til tabellformat
    filter(p.value < 0.05)                          # Filtrerer for signifikante resultater
}

# Bruker map med den definerte funksjonen for å analysere hver formel i listen
map(formulas, \(x) fn_tidy_lm(x))
