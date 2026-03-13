# Fremdriftslogg — tidyverse-presentasjon

---

## 2026-03-13

### Hva ble gjort

**Prosjektoppsett**
- Opprettet mappe og Quarto revealjs-presentasjon i `div`-repoet
- Tema-fil `stil.scss` skrevet fra bunnen med Google Fonts (Lora, Source Sans 3, Fira Code), tilpassede farger (terracotta, sage, cream) og egendefinerte CSS-klasser

**Presentasjonsinnhold**
- Målgruppe: R-brukere med grunnleggende kjennskap, fokus på lesbare skript
- Datasett: `palmerpenguins`
- Kjerneverktøy: `dplyr` (filter, select, mutate, summarise) og `tidyr` (pivot_longer, pivot_wider)
- Pedagogisk mønster: kode til venstre med gult markert verb, Før/Etter-tabeller til høyre

**Endringer underveis**
- Workflow-figur (R4DS-modellen) laget med inline HTML — CSS-klasser virket ikke i Pandoc, måtte bruke `{=html}`-blokker for alt rå HTML
- Verb-markering med `<mark style="...">` inne i `<pre>`-blokker (ikke knitr-blokker) for gul highlight på funksjonsnavn inne i koden
- Seksjonsdeler (01 dplyr / 02 tidyr / 03 Lesbarhet) med `{background-color="#FAFAF7"}`
- Mørk tittelside via `title-slide-attributes`

**Del 3: Lesbarhet og reproduserbarhet**
- Web-søk via agent for å finne beste praksis
- 5 slides: prosjektstruktur, kommentering, lesbar kode, RStudio-innstillinger, filorganisering

### Filer endret
- `2026-03-13 tidyverse-presentasjon.qmd` — hovedfil
- `stil.scss` — tema

### Kjente problemer ved avslutning
- Overlapp mellom tabeller i høyre kolonne på verb-slidene (delvis forbedret, ikke helt løst)
- Lesbarhetsslides (18–20) hadde overlapp, delvis fikset med mindre font og tettere linjeavstand
