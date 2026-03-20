# Fremdriftslogg — tidyverse-presentasjon

---

## 2026-03-19 (økt 3)

### Hva ble gjort

**Strukturelle endringer — full rewrite av QMD**
- Åpningsslide splittet: slide 1 viser kun dårlig kode, slide 2 ny "Slik kan det samme se ut" med `df_uforetrygd_panel`, seksjonsoverskrifter og `why`-kommentarer
- Workflow-figur (slide 3): fjernet alle pakke-hekser — fokus på analyseprosessen. Ny slide 4 har samme figur MED hekser (terracotta + lyse)
- Ny slide: "Uten pipe — koden leses innenfra og ut" (kun venstre del, nestet kode)
- Ny slide: "Pipe gir en logisk rekkefølge" (pipe-versjon med key-box)
- Nye verb-slides: `select()`, `arrange()`, `group_by()` — samme mønster med gul highlight og resultat-tabell
- `group_by()`-sliden noterer `.by = species` som moderne alternativ
- "5 tips"-oversikt flyttet til etter verbdemoen (etter `group_by()`)
- "tidyverse er ikke alltid svaret" flyttet til rett før lesetips
- Lesetips: data.table lagt til som fjerde kilde
- Avslutningsslide erstattet med Coase-sitat + Claude-signatur

**Kommentar-slides (tip 4)**
- Slide 21: rød bakgrunn (`#FFD0CE`) på dårlige kommentarer (venstre)
- Ny slide 22: grønn bakgrunn (`#D4F0D4`) på gode kommentarer (høyre), venstre uten rød

**Funksjon-slides (tip 5)**
- Splittet i to: slide 1 viser kun "Uten funksjon", slide 2 viser kun "Med funksjon"
- `reg`, `"Oslo"` og `"Bergen"` markert med gul highlight i funksjonsdefinisjon og kall

**"tidyverse ikke alltid svaret"**
- Endret fra to kolonner til vertikalt stablede bokser

**Publisering**
- `embed-resources: true` lagt til — løste problem med manglende ressurser på Quarto Pub
- Publisert til `https://eirikala.quarto.pub/along-the-way-in-time`
- GitHub remote endret fra HTTPS til SSH

### Filer endret
- `2026-03-13 tidyverse-presentasjon.qmd` — full rewrite
- `2026-03-13 tidyverse-presentasjon.html` — re-rendret med embed-resources

### Totalt antall slides: 27

### Kjente problemer ved avslutning
- Ingen kritiske.

---

## 2026-03-18 (økt 2)

### Hva ble gjort

**Stor versjon for PDF-eksport**
- Laget `2026-03-13 tidyverse-presentasjon-stor.qmd` med `embed-resources: true` og `theme: stil-stor.scss`
- `stil-stor.scss` — kopi av `stil.scss` med større tabellfonter (0.88em) og kodeblokker (0.80em)
- Lagt til `@media print`-regler i `stil-stor.scss`: `@page {size: 11in 6.875in}`, kode-wrapping, fjerne scroll-barer

**PDF-eksport — forsøk og status**
- Chromium snap-versjon blokkerer subprocess-kall (exit 144) fra Claude Code
- Ghostscript-workaround: kilde-PDF (Letter portrait, 612×792 pts) post-prosessert til 900×562.5 pts (16:10 landscape) via scale+translate
- Resultat: `tidyverse-2026-landscape.pdf` (215KB, 26 sider, riktig sideformat)
- Kode-wrapping i print ikke testet (kilde-HTML ikke regenerert etter CSS-endring)
- **Anbefalt neste steg:** Kjør render + PDF-kommando manuelt i terminal (snap-begrensning gjelder ikke der)

**Publisering**
- `tidyverse-2026.html` publisert til Quarto Pub via homepage-repoet
- `presentations.qmd` oppdatert med lenke

**manus.md opprettet**
- 40-minutters manus med kulepunkter per slide

### Filer endret
- `2026-03-13 tidyverse-presentasjon-stor.qmd` — ny fil (stor versjon)
- `stil-stor.scss` — ny fil (større fonter + print-CSS)
- `make_pdf.py`, `make_pdf.js` — hjelpeskript for PDF-generering (kan slettes)
- `tidyverse-2026.pdf` — siste genererte PDF (Letter-format, 272KB)
- `tidyverse-2026-landscape.pdf` — post-prosessert 16:10 (215KB)
- `manus.md` — foredragsmanus

### PDF-kommando for manuell kjøring i terminal
```bash
cd "/home/eirik/Documents/div/tidyverse-presentasjon"
# Render først:
/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto render "2026-03-13 tidyverse-presentasjon-stor.qmd" --to revealjs
# Generer PDF:
python3 -m http.server 8766 &
sleep 2
chromium-browser --headless --disable-gpu \
  --print-to-pdf="tidyverse-2026.pdf" \
  --print-to-pdf-no-header \
  --no-margins \
  --paper-width=11 \
  --paper-height=6.875 \
  --virtual-time-budget=20000 \
  "http://localhost:8766/2026-03-13%20tidyverse-presentasjon-stor.html?print-pdf"
pkill -f "http.server 8766"
```

### Kjente problemer ved avslutning
- PDF-sideformat er Letter (612×792) fordi snap-chromium ignorerer `--paper-width`/`--paper-height` fra subprocess. Løs ved manuell kjøring i terminal.
- `make_pdf.py` og `make_pdf.js` kan slettes — de er ikke i bruk.

---

## 2026-03-18 (økt 1)

### Hva ble gjort

**Workflow-figur**
- Fargede hekser (dplyr, stringr, forcats, lubridate) flyttet til `top:-30px, z-index:10` — ligger nå synlig over Transform-boksen
- Slide 1 omdøpt til "Å gjøre dataanalyse", slide 2 til "tidyverse"

**Nytt innhold**
- Ny slide (steg 1b i pipe-seksjonen): `mutate()` med `stringr::str_detect()` og `forcats::fct_other()` — med inline `#`-kommentarer og forklaring under kodeblokken
- Lesetips-slide lagt til som nest siste slide: r4ds, Posit cheat sheets, Tidyverse Style Guide

**5 tips for lesbare skript — omstrukturert**
- Oversiktssliden oppdatert til: pipe · prosjektstruktur · seksjonsoverskrifter · kommentarer · function()
- Tip 3: Seksjonsoverskrifter med `##` — stor kodeblokk med reelt eksempel (Import / Data rens / Export), key-box med `Ctrl+Shift+R`-tips
- Tip 4: Kommentarer — to kolonner (unngå/gjør), nummerkoder forklares
- Tip 5: Egne funksjoner — copy/paste-fellen vs. `function()`
- Gammel "5. Filorganisering"-slide fjernet
- Oppsummering-slide fjernet

**Diverse**
- SVG-tre på prosjektstruktur-sliden sentrert (`display:block; margin:0 auto`)
- Forfatternavnet gjort hvit på tittelsiden — krevde ny CSS-selektor `.quarto-title-author-name` (Quarto bruker `div`, ikke `p`)

### Filer endret
- `2026-03-13 tidyverse-presentasjon.qmd` — hovedfil
- `stil.scss` — forfatter-farge på tittelsiden

### Kjente problemer ved avslutning
- Ingen kritiske. Ny slide 9 (stringr/forcats) ikke testet på mindre skjermer.

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
