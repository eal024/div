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

## Versjon 3: kartografisk omarbeiding (2026-09-24, kveld)

Eirik var ikke fornøyd med v2. Kritikk og web-søk (Axis Maps Cartography
Guide, Field 2014 om gjennomsiktighet, Wilke kap. 15, ggplot2-boka, Roelfs
om Norge-kart) ga disse endringene:

- Projeksjon UTM 33 (EPSG:25833) i stedet for rå lon/lat. Egen base-R-funksjon
  `fn_utm33()` (Karneys serie), sjekket mot Kartverket: avvik under 1 cm.
- Figur/grunn: sjø i svak blå, Norge lys varm grå, naboland (Natural Earth
  50m) i mørkere grå med lavere kontrast, tynn kystlinje.
- Symboler skalert etter areal, største tegnes først, hvit kant i stedet for
  gjennomsiktighet. Kontor uten ansatt-tall som hule ringer, ikke «minste punkt».
- Åtte bynavn i grått, manuelt plassert. Oslo i innfelt ramme i havet vest for
  Nordland, med samme ramme på hovedkartet. Målestokk 200 km.
- Tittel som sier budskapet, undertittel med definisjoner, kilde nederst.
- Stolpepanelet fjernet: kartet er figuren.

Kjente svakheter: Trondheim-etiketten ligger tett på symbolene; Sverige og
Finland tar mye plass til høyre; 64 kontor mangler ansatt-tall i Brreg.

## Versjon 4: ekte kystlinje, roligere farger, mindre tekst (2026-09-24, sent)

Eiriks kritikk av v3: uklare landlinjer, Oslo-kontorene lå «på vannet»,
matte farger, for mye tekst, æøå vistes ikke. Årsak til de to første:
Kartverkets fylkespolygoner går ut til grunnlinjen og fyller fjordene.

- Kyst: geoBoundaries ADM0 (OpenStreetMap, 1,7 mill. punkter). Forbehandlet
  i Python (kjørt i økten, ikke lagret som skript): Douglas-Peucker med
  toleranse 0,0015° (~100 m) og øyer under ~0,5 km fjernet → 73 000 punkter
  (`data/norge_kyst_hoved.json`); Sutherland-Hodgman-klipp av full
  oppløsning til boksen 10,30–11,15 Ø / 59,70–60,10 N → 9 400 punkter
  (`data/norge_kyst_oslo.json`). GADM 4.1 ble prøvd og forkastet: trappete
  i Oslo-målestokk og gamle fylkesgrenser.
- Farger: sjø #dfe9f2, land #fdfcfa, naboland #ebe9e4, kyst #7d8790,
  data Okabe-Ito rødoransje med hvit kant. Ingen fylkesgrenser.
- Tekst: tittel, én undertittel, kilde. Seks bynavn.
- æøå: `div.Rproj` sto med `Encoding: ASCII`; satt til UTF-8. Skriptet må
  åpnes på nytt i RStudio etter endringen.

## Versjon 5: interaktivt kart (2026-09-25)

Eirik ba om vurdering av v4 og alternative verktøy, særlig JavaScript med
zoom til Oslo og Trondheim. Vurderingen av v4: nasjonalt nivå ferdig, men
tittelen er en etikett, bynavn kolliderer med symboler, og Oslo-utsnittet
svarer ikke på hvilket kontor som er hvilket. Bynivået er der et statisk
kart kommer til kort.

Løsning: Leaflet.js-kart med Kartverkets gråtonefliser, publisert som
blogginnlegg på homepage. Filene ligger i
`figurer/2026-09-25_nav_kontor_interaktivt/` (kopi fra homepage, som er
privat). Se README der. Verktøy vurdert: leaflet (R), mapgl, tmap, ren
Leaflet.js, MapLibre, Observable Plot. Ren Leaflet.js valgt for full
kontroll og null avhengigheter ved render.

Det statiske kartet beholdes: det bærer budskapet i rapport og slides,
det interaktive er et oppslagsverktøy.
