# Todo — tidyverse-presentasjon

> **Overordnet:** Maks 40 min. Lesbare skript — ikke for detaljert.

---

## Neste økt

### PDF-eksport
- [ ] **Kjør render + PDF-kommando manuelt i terminal** — se kommando i progress.md (2026-03-18 økt 2). Snap-begrensning hindrer subprocess-kall, men direkte i terminal fungerer det.
- [ ] **Slett hjelpeskript** — `make_pdf.py` og `make_pdf.js` trengs ikke lenger

### Innhold
- [ ] **Palmer Penguins-pakken i lesetips** — legg til Horst et al. som fjerde kilde (data.table er nå fjerde — blir femte)

### Valgfritt / fremtidig
- [ ] Vurder `{.incremental}`-lister på lesbarhetsslidene for bedre flyt i presentasjon
- [ ] Sjekk om `kableExtra` er tilgjengelig — kan gi bedre kontroll over tabellstørrelse
- [ ] Sjekk overlapp på verb-slides (select, arrange, group_by) på mindre skjermer

---

## Fullført

- [x] Workflow-figur: hekser frikoblet fra bokser, fargede hekser over Transform med z-index
- [x] Slide 1 heter "Å gjøre dataanalyse", slide 2 heter "tidyverse" → erstattet med ny struktur
- [x] Palmer Penguins: pingviner nederst til høyre, større tabell, uten heksogram
- [x] Pipe-seksjon: filter → mutate → summarise med gul highlight
- [x] Ny slide: mutate() med stringr::str_detect() og forcats::fct_other()
- [x] 5 tips oppdatert: pipe · prosjektstruktur · seksjonsoverskrifter · kommentarer · function()
- [x] Tip 3: Seksjonsoverskrifter med ## og Ctrl+Shift+R-tips
- [x] Tip 4: Kommentarer — rød på dårlige, grønn på gode (to slides)
- [x] Tip 5: Egne funksjoner — copy/paste-fellen vs. function(), reg markert gult
- [x] Prosjektstruktur: SVG-tre, sentrert
- [x] Lesetips: r4ds · posit cheatsheets · style.tidyverse.org · data.table
- [x] Åpningsslide splittet: dårlig kode alene, deretter rent eksempel med df_uforetrygd_panel
- [x] Workflow-figur uten pakker (slide 3), med pakker (slide 4)
- [x] Ny slide: "Uten pipe — innenfra og ut" + "Pipe gir en logisk rekkefølge"
- [x] Nye verb-slides: select(), arrange(), group_by()
- [x] "5 tips"-oversikt flyttet til etter verbdemo
- [x] "tidyverse ikke alltid svaret" flyttet til før lesetips, boksene stablet vertikalt
- [x] Avslutning: Coase-sitat + Claude-signatur
- [x] embed-resources: true lagt til — presentasjon fungerer på Quarto Pub
- [x] Publisert til Quarto Pub
- [x] GitHub remote endret til SSH
