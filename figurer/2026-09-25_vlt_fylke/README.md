# Varig lønnstilskudd per fylke, 2024–2026

Laget 2026-09-25. Datapipeline for blogginnlegget «Flyttet 2026-budsjettet
varig lønnstilskudd mellom fylkene?» på homepage (privat repo, derfor kopi her):
https://eirikala.quarto.pub/along-the-way-in-time/posts/2026-09-25_vlt_fylke/

Spørsmål: fra 2026 har varig lønnstilskudd egen post (kap. 634 post 75,
1 033 mill. kr, hvorav 1 008 mill. flyttet fra post 76). Flyttet det plasser
fra fylker med mange plasser per person med nedsatt arbeidsevne til fylker
med få? Svar i innlegget (revidert samme dag etter innspill): avstanden
mellom gruppene krymper i samme tempo før og etter januar 2026. Eneste
signal er januarhakket 2026, som traff bare toppgruppen. Fordelingsnøkkelen
er ikke offentlig dokumentert.

Lærdom: klassifisert på desember 2025 (bruddmåneden) så tempoet ut til å
dobles; klassifisert på 2024-gjennomsnitt forsvant det. Grupper må velges
på nivå før bruddet, og indeksering til bruddmåneden gir falsk konvergens.

| Fil | Innhold |
|---|---|
| `lag_data.R` | Leser Excel-filene i `data/raw/`, skriver JSON til `data/web/` |
| `data/raw/tilt110_*.xlsx` | Nav TILT110, lønnstilskudd, ark «Tiltak og fylke». Des. 2024, des. 2025, aug. 2026 |
| `data/raw/ned150_*.xlsx` | Nav NED150, nedsatt arbeidsevne, ark «1a. Fylke Antall» og «2a. Fylke Prosent av befolkning» |
| `data/web/lonnstilskudd_fylke.json` | fylke × måned × tiltak (varig, midlertidig), antall |
| `data/web/nedsatt_fylke.json` | fylke × måned, antall og prosent av befolkningen |
| `data/web/andel_fylke.json` | 2024-snitt: VLT per 1 000 med nedsatt arbeidsevne per fylke, gruppe |
| `data/web/gruppe_serie.json` | per måned og gruppe: VLT, nedsatt arbeidsevne, plasser per 1 000 |
| `data/web/gruppe_differanse.json` | per måned: differanse i plasser per 1 000, flest minus færrest |
| `data/web/januar.json` | desember til januar per gruppe, 2025 og 2026 |
| `data/web/fylke_serie.json` | per fylke og måned: VLT, nedsatt arbeidsevne, plasser per 1 000, gruppe |

Kilder: nav.no, «Tiltaksdeltakere» og «Personer med nedsatt arbeidsevne»,
arkivsider per år. TILT110 har også ark «Tiltak og kommune» fra 2025, men
celler under 4 er sensurert.
