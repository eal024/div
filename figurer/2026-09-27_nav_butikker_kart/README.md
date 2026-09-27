# Nav-kontor, dagligvarebutikker og kommunegrenser

Laget 2026-09-27. Interaktivt Leaflet-kart med tre lag: kommuner farget etter
Nav-tilstedeværelse (kontor / bare publikumsmottak / ingen), dagligvarebutikker
etter kjedegruppe, og Nav-kontor og mottak. Publisert som blogginnlegg:
https://eirikala.quarto.pub/along-the-way-in-time/posts/2026-09-27_nav_butikker_kart/

Kartfilene (kart.js, kart.css, kart.html, index.qmd) er kopiert hit fra
homepage-repoet (privat). Her ligger også datapipelinen og dataene.
Åpne kart.html via en lokal server med `data/` pekende på `data/web/`
(eller kopier `data/web/*` til `data/`).

| Fil | Innhold |
|---|---|
| `last_ned_kommuner.sh` | Henter 357 kommunepolygoner fra Kartverkets kommuneinfo-API til `data/kommuner/` (38 MB, ikke i git) |
| `koble_kommune.py` | Slår sammen polygonene, og kobler butikker og mottak til kommune med mapshaper (romlig join) |
| `lag_data.R` | Avstand fra hver butikk til nærmeste Nav-punkt (mottak + kontor), kommunetall, skriver `data/web/` |
| `data/web/kommuner.geojson` | 357 kommuner, forenklet 6 % med mapshaper (1,1 MB) |
| `data/web/fylker.geojson` | 15 fylker, sammenslått fra kommunene |
| `data/web/kommune_stat.json` | per kommune: status, antall butikker og kiosker, medianavstand, nærmeste kontor |
| `data/web/butikker.json` | 6 141 butikker (helper::dagligvare, uten Svalbard) med kjede, gruppe, kiosk, avstand og nærmeste Nav |
| `data/web/navpunkter.json` | 350 Nav-punkter: kontoradresse (fylt) og mottak utenfor kontoret (hul), fra helper::nav_mottak og helper::nav_kontor. Hjelpemiddelsentralenes mottak er tatt ut |

Kjør i rekkefølge: `./last_ned_kommuner.sh`, `python3 koble_kommune.py`, `Rscript lag_data.R`.
mapshaper hentes med `npx -y mapshaper` (krever node).

Nøkkeltall (september 2026): 221 kommuner med Nav-kontor, 99 med bare mottak,
37 uten. 5 922 butikker utenom kiosk; median 2 km til nærmeste Nav, 70 prosent
innen 5 km, 96 prosent innen 20 km. Avstand er storsirkel, ikke vei.

Vurdering før publisering (to agenter): de 37 må være figuren, ikke Nav-prikkene;
butikk-canvas over kommune-SVG blokkerte klikk (løst ved felles canvas i samme
pane); hjelpemiddelsentralenes mottak lå i nav_mottak og forskjøv avstandene.

## Tillegg 2026-09-27 (senere samme dag)

- Nav-kontor tegnes som kryss (divIcon med SVG), mottak utenfor kontoret som hul ring.
- Kommunegrenser tydeligere (mørkere kant, 0,8 px nasjonalt, 1,6 px i by-zoom).
- Bydelsgrenser for Oslo (17), Bergen (8), Trondheim (4) og Stavanger (8) fra
  OpenStreetMap, admin_level 9, hentet med Overpass (`hent_bydeler_overpass.txt`,
  rå svar i `data/bydeler_osm.json`, ikke i git). `overpass-api.de` ga 504,
  `z.overpass-api.de` fungerte. Konvertert med `npx osmtogeojson`, forenklet 15 %
  med mapshaper til `data/web/bydeler.geojson` (79 KB). Vises fra zoom 9,5,
  stiplet, med navn ved hover. Lisens ODbL, attribusjon i kartet.
  Geonorge/Kartverket har ikke bydelsgrenser som åpent datasett; SSB har bare kodene.
