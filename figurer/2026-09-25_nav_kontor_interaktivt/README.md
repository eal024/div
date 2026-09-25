# Interaktivt kart over Navs lokalkontor

Laget 2026-09-25. Leaflet-kart (ren JavaScript, ingen byggesteg) over de 243
lokalkontorene i `helper::nav_kontor`, med Kartverkets gråtonekart som grunn.
Symbolareal = registrerte ansatte, farge = drop-in eller kun timeavtale,
hule ringer = kontor uten ansatt-tall.

Publisert som blogginnlegg:
https://eirikala.quarto.pub/along-the-way-in-time/posts/2026-09-25_nav_kontor_interaktivt/

Filene her er en kopi av innleggsmappa i homepage-repoet (privat), lagt her
fordi innlegget lenker hit.

| Fil | Innhold |
|---|---|
| `lag_data.R` | Eksporterer `helper::nav_kontor` til `nav_kontor.json` |
| `nav_kontor.json` | 243 kontor: navn, adresse, kommune, ansatte, drop-in, lat, lon |
| `kart.js` | Kartet: symboler, tegnforklaring, søk, byknapper, språk |
| `kart.css` | Stil for kontroller, tegnforklaring og popup |
| `kart.html` | Selvstendig fullskjermside. Åpne via en lokal server (`python3 -m http.server`), siden data hentes med `fetch` |

Det statiske kartet (ggplot2) ligger i `../2026-09-24_nav_kontor_kart/`.
