# Todo — tidyverse-presentasjon

---

## Neste økt

### Formatering og overlapp
- [ ] **Løs overlapp i verb-slides** — tabellene i høyre kolonne (Før/Etter) passer ikke. Vurder:
  - Bytte til én tabell per slide (kun "Etter") og beskrive "Før" i teksten
  - Bruke `kableExtra` for å styre tabellhøyde eksplisitt
  - Redusere til én kolonne og vise Før → Etter vertikalt med pilsymbol
- [ ] **Overlapp i lesbarhetsslides (18–20)** — `<pre>`-blokkene er fortsatt for store på noen skjermer
- [ ] **Vurdere Beamer** — er Quarto revealjs riktig format, eller passer Beamer (PDF) bedre til dette publikummet? Fordeler med Beamer: stabil layout, PDF fungerer overalt, ingen CSS-strid. Ulemper: mindre visuell kontroll, krever LaTeX-oppsett

### Innhold
- [ ] **Slide om datasettet** — legg til en kort slide tidlig i presentasjonen som forklarer Palmer Penguins-datasettet: hva det inneholder, hvilke variabler som brukes, og hvorfor det er valgt
- [ ] **Avansert seksjon** — legg til en egen seksjon (seksjon 04?) rettet mot viderekommende. Tittel: "Tips du kommer borti etterhvert". Mulig innhold:
  - `nest()` og `map()` — list-kolonner og iterasjon over grupper
  - Alternativer til dplyr: `data.table` (hastighet), `dtplyr` (dplyr-syntaks over data.table), `collapse` — med ærlig diskusjon av hva dplyr er svakt på (ytelse på store data)
  - Andre nyttige verktøy: `janitor::clean_names()`, `across()`, `glue::glue()`
- [ ] **Avslutningsslide: "Hva videre?"** — legg til en slide om hva som kommer etter dplyr/tidyr:
  - Visualisering med `ggplot2`
  - Modellering med `tidymodels` / `fixest`
  - Rapportering med Quarto / R Markdown
  - Henvisning til R for Data Science (r4ds.hadley.nz)
- [ ] **Legg til kilder** — slide eller fotnote med referanser:
  - Wickham et al. (2023), *R for Data Science*, 2. utg.
  - Tidyverse Style Guide (style.tidyverse.org)
  - Palmer Penguins-pakken (Horst et al.)

### Valgfritt / fremtidig
- [ ] PDF-eksport som backup (via `chromium --headless --print-to-pdf`)
- [ ] Vurder `{.incremental}`-lister på lesbarhetsslidene for bedre flyt i presentasjon
- [ ] Sjekk om `kableExtra` er tilgjengelig — kan gi bedre kontroll over tabellstørrelse
