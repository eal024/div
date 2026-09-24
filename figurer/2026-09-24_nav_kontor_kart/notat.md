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
