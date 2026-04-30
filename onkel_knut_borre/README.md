---
tittel: "Onkel Knut Børre Hansen — løp og sykkel"
forfatter: "Eirik"
dato: "2026-04-30"
---

# Onkel Knut Børre Hansen

## Kort beskrivelse

Knut Børre Hansen, 63 år (per 2026). Bodd på Østlandet store deler av livet,
men flyttet til Harstad-området for noen år siden. Aktiv mosjonist innen
**løp** og **sykkel**, uten klubbtilknytning. Har tidligere vært med på
større sykkelritt som **Birken (Birkebeinerrittet)** og **Den store
styrkeprøven** (Trondheim–Oslo). De siste årene har fokuset flyttet seg
mot løping.

## Datakilde og forbehold

Eirik forsøkte 2026-04-30 å finne konkrete resultater i offentlige databaser
([Birken/mika:timing](https://birkebeiner.r.mikatiming.com/),
[EQ Timing](https://live.eqtiming.com/),
[KONDIS](https://www.kondis.no/),
[Sportsidioten](https://www.sportsidioten.no/),
[Rittresultater.no](https://rittresultater.no/),
[Sykl.no](http://www.sykl.no/)).

**Ingen treff** ble funnet for "Knut Børre Hansen", "Knut Hansen + Harstad",
eller "Børre Hansen + Harstad" som med rimelig sikkerhet kan knyttes til onkel.
Mulige grunner:

- Påmeldt under variant av navnet (kun "Knut Hansen", uten mellomnavn)
- Eldre resultater er ikke indeksert/digitalisert
- Birkens egne resultatservice var "snart tilgjengelig" på søketidspunkt
- Større rittresultater bak innlogging eller ikke fritt søkbare

Tabellen under er derfor en **mal som må fylles inn manuelt** etter samtale
med onkel eller funn av startnummer/påmeldingskvitteringer. Strukturen er
laget slik at den kan leses direkte inn i R (`results.csv`) for plotting.

## Resultater

| dato | event | type | distanse_km | tid_hms | plassering | klasse | notat |
|------|-------|------|-------------|---------|------------|--------|-------|
| ÅÅÅÅ-MM-DD | Birkebeinerrittet | sykkel | 86 | hh:mm:ss | — | M55 | — |
| ÅÅÅÅ-MM-DD | Den store styrkeprøven | sykkel | 540 | hh:mm:ss | — | M55 | Trondheim–Oslo |
| ÅÅÅÅ-MM-DD | Eksempel halvmaraton | løp | 21.1 | hh:mm:ss | — | M60 | — |

Tøm de tre malradene over og legg inn faktiske resultater. Samme data ligger
også i `results.csv` (CSV-formatet er det R-skriptet leser).

## Plot

Se `plot_results.R`. Skriptet leser `results.csv` og lager:

1. Tidslinje av deltakelser (event over tid, fargelagt etter `type`)
2. Tempo (min/km) for løp, og snittfart (km/t) for sykkel — hvis tider er fylt inn

Kjør med `Rscript plot_results.R` fra denne mappa. Plot lagres som
`plot_tidslinje.png` og `plot_tempo.png`.

## Filer

- `README.md` — dette dokumentet
- `results.csv` — strukturerte data (fyll inn)
- `plot_results.R` — R-skript som lager plot fra CSV-en
