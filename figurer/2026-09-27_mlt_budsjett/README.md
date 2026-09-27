# Midlertidig lønnstilskudd per fylke og kommune, 2024–2026

Laget 2026-09-27. Datapipeline for blogginnlegget «Da pengene tok slutt:
midlertidig lønnstilskudd i andre halvår 2025» på homepage (privat repo,
derfor kopi i div):
https://eirikala.quarto.pub/along-the-way-in-time/posts/2026-09-27_mlt_budsjett/

Spørsmål: sommeren 2025 hadde flere Nav-fylker brukt mer enn rammen for
arbeidsmarkedstiltak, og direktoratet ga beskjed om at nye plasser ikke skulle
opprettes før budsjettet i det enkelte fylket var i balanse (stoppbrev fra
Nav Oslo og Nav Vest-Viken 13. august 2025). (1) Hvilke fylker kuttet mest fra
første til andre halvår 2025? (2) Hvor ulikt ble nabokommuner behandlet, også
over fylkesgrenser? (3) Byttet kommunene som kuttet, til andre tiltak?

Svar i utkastet: landet falt 62 prosent fra mai til desember 2025 (8 795 til
3 382). Alle fylker kuttet, fra 9 prosent (Innlandet) til 60 (Troms), mot
vekst på 2 til 30 prosent i samme halvår 2024. Spredningen mellom kommuner
innen et fylke er større enn mellom fylkene. Ingen substitusjon: arbeidstrening,
opplæring og avklaring falt også, og kommunene som kuttet lønnstilskudd mest,
kuttet andre tiltak mest (korrelasjon 0,35 i prosent over 99 kommuner).

| Fil | Innhold |
|---|---|
| `lag_data.R` | Leser Excel-filene i `data/raw/`, beregner halvår, nabopar og substitusjon, skriver JSON til `data/web/` |
| `data/raw/tilt1x0_*.xlsx` | Nav TILT100–TILT180, desember 2024, desember 2025 og august 2026. Ark «Tiltak og fylke» (alle år) og «Tiltak og kommune» (2025 og 2026; TILT100: «Tiltaksdeltakere og kommune») |
| `data/raw/harb100_202608.xlsx` | Nav HARB100 Sesongjusterte hovedtall om arbeidsmarkedet, august 2026 (helt ledige, delvis ledige, tiltaksdeltakere, arbeidssøkere) |
| `data/raw/kommuner.geojson` | 357 kommunepolygoner (Kartverket, forenklet), kopi fra `2026-09-27_nav_butikker_kart/data/web/` |
| `data/web/mlt_fylke.json` | fylke × måned × tiltak (midlertidig, varig), antall |
| `data/web/landet_tiltak.json` | landet: tiltaksgruppe × måned |
| `data/web/fylke_halvaar.json` | per fylke: snitt per halvår 2024–2026, mai og des. 2025, endringer i prosent, sortert etter kutt |
| `data/web/fylke_tiltak_halvaar.json` | fylke × tiltaksgruppe: snitt per halvår og endringer |
| `data/web/kommune_serie.json` | kommune × måned 2025–2026: lønnstilskudd (NA ved prikking) og alle tiltak |
| `data/web/kommune_halvaar.json` | per kommune: halvårssnitt, endringer, `paalitelig` (≥ 15 i H1 2025 og ingen prikking) |
| `data/web/kommune_tiltak_halvaar.json` | kommune × tiltaksgruppe, halvår 2025 |
| `data/web/hovedtall_sesongjustert.json` | landet × måned 2022–2026: helt ledige, delvis ledige, tiltak, arbeidssøkere i alt (sesongjustert) |
| `data/web/nabo_par.json` | kommunepar som deler grense, begge pålitelige, med endring og `kryss_fylke` |

Forbehold: celler under 4 er prikket, som gir 99 pålitelige av 358 kommuner.
Oslo er én linje, ingen bydeler. Kommunepolygonene omfatter sjøareal, så noen
nabopar går over en fjord (Moss–Tønsberg, Sortland–Harstad). Bruddet i
arbeidssøkerstatistikken fra april 2025 gjelder statusinndelingen, ikke
tellingen per tiltak, ifølge Navs «Om statistikken».

Kjør fra denne mappa: `Rscript lag_data.R`.
