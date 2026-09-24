# Kart over Navs lokalkontor

Laget 2026-09-24. Viser hvor de 243 lokalkontorene ligger (ett punkt per
kontor, beliggenhetsadresse), farget etter om publikum kan komme uten
timeavtale minst én ukedag (drop-in) eller ikke. Innfelt utsnitt for Oslo og
omegn der punktene ellers overlapper.

Data: `helper::nav_kontor` (nav.no NORG-record, geokodet via Kartverket).
Fylkesgrenser: Kartverkets kommuneinfo-API, cachet i `data/fylke_*.json`.

Budskap: kontorene følger bosettingen, tett langs kysten og i sør, spredt i
innlandet og nord. Drop-in er vanlig, men timeavtale-kontorene ligger ikke
bare i byene.

## Versjon 2: fordeling (2026-09-24, senere samme dag)

Skript på div-rota: `2026-09-24 nav_kontor_kart.R`. Fil
`2026-09-24_nav_kontor_fordeling.png`. Kart med punkt skalert etter ansatte
(Brreg, 64 kontor uten tall vises som minste punkt) og stolper med antall
lokalkontor per fylke (fylke fra kommunenummer, 2024-inndeling). Vestland
har flest kontor (34), Vestfold færrest (6); de største kontorene ligger i
Oslo, Bergen, Stavanger, Kristiansand, Trondheim og Tromsø.
