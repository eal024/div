# CLAUDE.md — Arbeidsregler for div

Dette dokumentet leses av Claude ved oppstart av hver økt.

---

## Regler som alltid gjelder

- **Slett aldri filer eller skript** — uansett grunn
- **Kopier, ikke flytt** — originalen skal alltid være trygg
- **Gjør ikke mer enn det du blir bedt om** — spør heller enn å anta
- **Bekreft destruktive operasjoner** — git reset --hard, rm -rf o.l. skal alltid bekreftes

---

## Filstruktur

```
./
├── CLAUDE.md                    # Dette dokumentet
├── README.md                    # Innholdsfortegnelse for repoet
├── tidyverse-presentasjon/      # Quarto revealjs-presentasjon om tidyverse
├── iterate/                     # purrr, map, apply
├── dplyr/                       # dplyr og tidyverse
├── data.table/                  # data.table
├── BaseR/                       # Base R
├── regression/                  # fixest og regresjon
├── visualization/               # ggplot2, plotly, tinyplot
├── shiny/                       # Shiny-apper
├── timeseries/                  # Tidsserier og ARIMA
├── quarto/                      # Quarto-maler og presentasjoner
├── analysis/                    # Analysecase
├── Textanalysis/                # Tekstanalyse
├── filemanagement/              # Filhåndtering med fs og purrr
├── excel/                       # openxlsx
├── api/                         # SSB API
└── data/                        # Datakilder
```

---

## Presentasjoner

Nye presentasjoner legges i egen mappe under roten, med dato-prefix: `YYYY-MM-DD navn/`.

Aktive presentasjoner med egne logger:
- `tidyverse-presentasjon/log/todo.md` — utestående oppgaver
- `tidyverse-presentasjon/log/progress.md` — øktlogg

### Verktøy

**Marp** (Markdown → PDF/HTML). Krever "Marp for VS Code"-utvidelse.

Påkrevd front matter:
```yaml
---
marp: true
paginate: true
html: true
---
```
`html: true` er nødvendig for at HTML-figurer skal rendres.

**Kompilering til PDF:**

Alternativ 1 — VS Code (anbefalt): Høyreklikk i Marp-forhåndsvisning → "Export slide deck" → PDF.

Alternativ 2 — HTML + nettleser:
```bash
npx @marp-team/marp-cli "filnavn.md" --output "filnavn.html" --html
```
Åpne i nettleser → `Ctrl+P` → Lagre som PDF.

**NB:** `--html` må alltid være med — uten det stripses alle HTML-figurer ut.

---

## Designprinsipper for slides

- **Én tanke per slide** — motstanden mot dette avslører at tanken ikke er ferdig tenkt
- **Titler er påstander, ikke etiketter** — ikke "VLT" men "VLT mangler kausalstudier"
- **Led med konklusjonen** — ikke bygg opp mot den, start med den
- **Kortere er bedre** — 10 slides du bruker er bedre enn 20 du blar forbi
- **Kulepunkter er en innrømmelse av nederlag** — finn strukturen (sekvens, kontrast, hierarki, kausal kjede) og gjør den synlig
- **Visuelt hierarki er mening** — størrelse, posisjon og luft gjør det kognitive arbeidet for publikum
- **Avslutt bevisslider med konklusjonsboks** — én boks nederst med det ene publikum skal ta med seg
- **Skille mellom det du vet og det du tror** — ikke skjul usikkerhet bak like store overskrifter

---

## Fargepalett (Marp-tema)

| Variabel | Hex | Bruk |
|---|---|---|
| `--navy` | `#1C2B3A` | Primærtekst, tabelloverskrifter, tittelslide-bakgrunn |
| `--offwhite` | `#F8F7F4` | Slidebakgrunn |
| `--terracotta` | `#B85C38` | Overskriftskant (h1), h2-farge, sitat-kant, punktliste-markør |
| `--sage` | `#5C7A6E` | h3, kodeblokk-kant, positiv status |
| `--warm-grey` | `#E8E3D9` | Figurbokser |
| `--mid-grey` | `#9A9590` | Sidenummerering, undertekst |
| `--code-bg` | `#EEF0F3` | Bakgrunn for kodeblokker |

Slidetyper: standard (off-white), `title` (navy bakgrunn), `closing` (beige `#EDE8DF`).

CSS-blokk: kopier fra `research-project/decks/2026-03-07 phd-oversikt/2026-03-07 helhet_skisse.md`.

---

## HTML-figurer

Bruk stylede HTML-bokser fremfor ASCII-diagrammer.

### Fargekonvensjoner for noder

| Node | Kantfarge |
|---|---|
| Instrument (Z) | `#5C7A6E` (sage) |
| Behandling / mediator (D, M) | `#1C2B3A` (navy) |
| Utfall (Y) | `#B85C38` (terracotta) |

### Mønstre

Fullstendige HTML-mønstre for kausal kjede, trestruktur, store tall, nøkkelfunn-boks,
nummererte sirkler, to-kolonne sammenligning og pipeline:
se `research-project/decks/prinsipper.md`.

---

## Git-rutine

Commit etter meningsfulle endringer:

```bash
git add .
git commit -m "kort beskrivelse av hva som ble gjort"
```

Push kun ved eksplisitt bekreftelse fra bruker.
