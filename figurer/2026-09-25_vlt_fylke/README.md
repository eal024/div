# Varig lønnstilskudd per fylke, 2024–2026

Laget 2026-09-25. Datapipeline for blogginnlegget «Flyttet 2026-budsjettet
varig lønnstilskudd mellom fylkene?» på homepage (privat repo, derfor kopi her):
https://eirikala.quarto.pub/along-the-way-in-time/posts/2026-09-25_vlt_fylke/

Spørsmål: fra 2026 har varig lønnstilskudd egen post (kap. 634 post 75).
Flyttet det plasser fra fylker med mange plasser per person med nedsatt
arbeidsevne til fylker med få? Svar i innlegget: tilnærming mellom gruppene,
men den startet i 2024, ikke i januar 2026.

| Fil | Innhold |
|---|---|
| `lag_data.R` | Leser Excel-filene i `data/raw/`, skriver JSON til `data/web/` |
| `data/raw/tilt110_*.xlsx` | Nav TILT110, lønnstilskudd, ark «Tiltak og fylke». Des. 2024, des. 2025, aug. 2026 |
| `data/raw/ned150_*.xlsx` | Nav NED150, nedsatt arbeidsevne, ark «1a. Fylke Antall» og «2a. Fylke Prosent av befolkning» |
| `data/web/lonnstilskudd_fylke.json` | fylke × måned × tiltak (varig, midlertidig), antall |
| `data/web/nedsatt_fylke.json` | fylke × måned, antall og prosent av befolkningen |
| `data/web/andel_fylke.json` | des. 2025: VLT per 1 000 med nedsatt arbeidsevne, andeler, gruppe |
| `data/web/vlt_indeks.json` | VLT indeksert til des. 2025 = 100, med gruppe |

Kilder: nav.no, «Tiltaksdeltakere» og «Personer med nedsatt arbeidsevne»,
arkivsider per år. TILT110 har også ark «Tiltak og kommune» fra 2025, men
celler under 4 er sensurert.
