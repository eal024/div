# div

Dette repositoryet inneholder personlige R-skript, Quarto/R Markdown-notater, eksempler og små verktøy for databehandling, visualisering og rapportering. Målet er å samle gjenbrukbare funksjoner, eksperimentelle analyser og dokumentasjon på ett sted.

Status
- Nåværende status: aktiv utvikling
- Hovedkontakt: eal024

Hurtigoversikt — foreslått struktur
- `src/` — gjenbrukbare funksjoner og helper-skript (.R, .r)
- `analyses/` — dato-stemplede analyse- og eksperiment-skript
- `notebooks/` — Quarto / R Markdown / TeX-kilder
- `docs/` — dokumentasjon, guider og templates
- `assets/` — statiske filer og bygde outputs
  - `assets/images/`
  - `assets/outputs/`
  - `assets/css/`
- `data/` — datasett (xlsx, csv)
- `scripts/` — verktøysskript for reorganisering og vedlikehold
- `tests/` — testfiler (hvis relevant)
- `legacy/` — eldre filer som bevares for historikk

Hvorfor denne reorganiseringen
- Bedre oversikt: samle gjenbrukbare funksjoner i `src/` og analysene i en egen mappe gjør repoet lettere å navigere.
- Mindre rot i root: store bygde filer og outputs flyttes til `assets/`.
- Reproduserbarhet: Quarto/RMarkdown-kilder plasseres i `notebooks/` for enklere rendering.

Hva som er gjort i denne branchen
- Denne branchen inneholder en oppdatert README.md med anbefalt struktur og et par helper-skript som genererer flytte-kommandoer (dry-run) og et Python-skript som kan brukes for å anvende flytting lokalt.
- Merk: Jeg har ikke automatisk flyttet alle filer i denne committen. Før vi gjør masseflytt, anbefales det å kjøre dry-run, verifisere og så gjøre endringer i en PR.

Hvordan bruke reorganiserings-skriptet
1. Sjekk ut branchen:
   git fetch origin
   git checkout reorganize/auto
2. Les gjennom `scripts/MOVE_LIST.sh` for en komplett liste med foreslåtte `git mv`-kommandoer.
3. Kjør dry-run (ingen endringer gjort):
   bash scripts/MOVE_LIST.sh --dry-run
4. Når du er klar, kjør på din lokale maskin uten --dry-run for å utføre `git mv`-kommandoene, kjør test-suite og opprett PR.

Sjekkliste før merge
- Kjør testene (evt. render notebooks) for å avdekke eventuelle brudd i imports eller relative paths.
- Oppdater imports/path i kode hvis nødvendig.
- Forsikre deg om at store binærfiler som skal beholdes er ønsket i repoet (vurder Git LFS hvis nødvendig).

Kontakt
- Repo-eier: eal024
- For spørsmål eller forespørsler: opprett issue i repoet.