# R — skript og konsepter

En samling skript for å lære og referere til R-teknikker. Organisert etter tema, fra funksjonell programmering til analyse og visualisering.

## Innhold

| # | Tema | Innhold |
|---|------|---------|
| 1 | [Small smart coding parts](#small-smart-coding-parts) | Nyttige enkeltfunksjoner og triks |
| 2 | [API and query](#api-and-query) | SSB API og datauttak |
| 3 | [Functional / Iteration](#functional--iteration) | `map`, `walk`, `apply`, `reduce` |
| 4 | [R and Excel](#r-and-excel) | Les og skriv Excel-filer |
| 5 | [Data.table](#datatable) | Rask datahåndtering med data.table |
| 6 | [dplyr / tidyverse](#dplyr--tidyverse) | Datarensing og transformasjon |
| 7 | [Base R](#base-r) | Innebygde R-funksjoner |
| 8 | [Regression](#regression) | fixest og regresjonsmodeller |
| 9 | [Visualization](#visualization) | ggplot2, plotly, tinyplot |
| 10 | [Shiny](#shiny) | Interaktive webapper |
| 11 | [Time series](#time-series) | Tidsserieanalyse og ARIMA |
| 12 | [Quarto](#quarto) | Rapporter og presentasjoner |
| 13 | [Analysis / Cases](#analysis--cases) | NAV, velferd og analysecase |
| 14 | [Textanalysis](#textanalysis) | Tekstanalyse med tidytext |
| 15 | [File management](#file-management) | Filhåndtering med fs og purrr |

---

## Small smart coding parts

Korte skript som viser én nyttig funksjon eller teknikk om gangen — godt utgangspunkt for å lære isolerte konsepter.

- `expand_grid()` — Alle kombinasjoner av to vektorer; nyttig for grid-søk og scenariobygging. [script →](./BaseR/expand_grid_test.R)
- `quantile()`, `cut()` — Del data i kvantilgrupper og tilordne observasjoner til percentilintervaller. [script →](./analysis/quantile_function.R)
- datapasta — Lim inn data fra utklippstavlen direkte som R-kode med `datapasta`-pakken. [script →](./BaseR/datapasta.R)

---

## API and query

Spørringer mot SSBs PxWebApi — fra enkel tabell-henting til regionale framskrivninger.

- SSB API — henter tabell 07459 (befolkning etter kjønn, alder og år) med `httr` og `jsonlite`. [script →](./api/api_ssb_befolkning.R)
- SSB befolkningsframskrivning, fylkesvis — regionalt brutt ned på fylke med ulike scenarioer fra SSB. [script →](./api/ssb_befolkningframskrivning_fylkesvis.R)
- Faktisk befolkning, fylkesvis og aldersgrupper — kombinerer geografi og aldersstruktur i ett uttrekk. [script →](./api/faktisk_befolkning_fylkesvis_aldersgrupper.R)
- Befolkningsframskrivning, nasjonalt — nasjonale framskrivningsdata fra SSB sammenstilt over tid. [script →](./api/befolkningsframskrivning.R)

---

## Functional / Iteration

`purrr`-pakken og Bases apply-familie. Felles mål: erstatt løkker med funksjoner som er lettere å lese og teste.

- `map()`, `pwalk()` — introduksjon til høyere-ordens funksjoner; send funksjoner som argumenter og iterer uten løkker. [script →](./iterate/2022-09-01%20functional.R)
- `map()`, `walk()`, `imap()`, `pmap()`, `reduce()`, `accumulate()` — fullstendig purrr-gjennomgang inkludert predikatfunksjoner og funksjons-fabrikker. [script →](./iterate/2022-09-23%20functional.R)
- `sapply()`, `lapply()`, `vapply()`, `tapply()` — apply-familien i Base R med purrr-ekvivalenter side om side. [script →](./iterate/2023-03-27%20apply_family.R)
- `keep()`, `discard()`, `map()` — filtrer listeelementer med predikatfunksjoner og iterer over nestede strukturer. [script →](./iterate/2025-01-06%20purrr.R)
- `apply()`, `map_dbl()` — iterasjon over rader og kolonner med ytelsessammenligning mot for-løkke. [script →](./iterate/2025-01-08%20iteration_column_or_rows.R)
- `every()`, `some()`, `safely()` — sjekk om alle/noen elementer oppfyller en betingelse; innhyl funksjoner for å håndtere feil uten å stoppe kjøringen. [script →](./iterate/2025-01-08%20purrr_predicate.R)
- `compose()`, `partial()` — sett funksjoner i kjede og lag partielle funksjoner for konsis kode. [script →](./iterate/2025-01-15%20purrr_negate_compose_partial.R)
- `keep()`, `flatten()`, `compact()`, `compose()` — rens og flatgjør nestede listestrukturer. [script →](./iterate/2025-01-16%20keep_discard_and_list.R)
- `apply()`, `lapply()`, `sapply()`, `mapply()` — oversikt over alle fire apply-varianter med eksempler. [script →](./iterate/2025-01-25%20apply_family.R)
- `accumulate()`, `reduce()`, `compose()` — sammenligner akkumulering og reduksjon; `compose()` med flere funksjoner samtidig. [script →](./iterate/2025-04-11%20recap_accumulate.R)
- `accumulate()`, `done()` — retning, tidlig avslutning, random walk og Pascals trekant. [script →](./iterate/accumlate_function.R)

---

## R and Excel

Les og skriv Excel-filer fra R med `openxlsx` — fra enkel skriving til formaterte rapporttabeller.

- openxlsx — grunnleggende bruk: opprett arbeidsbok, skriv data, lagre fil. [script →](./excel/openxl.R)
- openxlsx — avansert: styling, multiple sheets og celleformatering. [script →](./excel/openxl_example2.R)
- Eksportere tabeller til Excel — ferdigstilte tabeller fra R direkte til xlsx med riktig format. [script →](./excel/ex_openexcel.R)
- Budsjett-tabeller til Excel — budsjettdata med summering, formatering og uthevede rader. [script →](./excel/budsjett_tabeller_til_Excel.R)
- Importere tabell med tekst — håndtering av blandede kolonntyper og tekstformatering ved innlesing. [script →](./excel/import_tabell_med_tekst.R)

---

## Data.table

`data.table` er et alternativ til dplyr med vesentlig høyere ytelse på store datasett. Syntaksen `DT[i, j, by]` tilsvarer filter / select+mutate / group_by.

- Grunnleggende `data.table` — syntaks for `[i, j, by]`, referansesemantikk og nøkkeloperasjoner. [script →](./data.table/2022-08-17%20data.table.R)
- data.table by needs — vanlige oppgaver: filtrer, transformer og aggreger med data.table-syntaks. [script →](./data.table/2022-08-31%20data.table_by_needs.R)
- data.table — Grant McDermott — gjennomgang basert på McDermotts forelesningsnotater; dekker joins og avansert bruk. [script →](./data.table/2022-10-18%20data.table_grant_mcdermott.R)
- data.table konsepter — referansesemantikk, keys, joins og set-funksjoner. [script →](./data.table/2022-11-22%20data.table_consepts.R)
- `paste()`, strengsammenslåing per gruppe — kollapse strenger innen grupper med data.table. [script →](./data.table/2024-05-13%20collapsing_strings.R)
- Ytelsessammenligning: data.table vs dplyr — tidsmåling på like operasjoner i begge rammeverk. [script →](./data.table/2022-11-14%20timeing_data.table_dplyr.R)
- Oppsummering data.table — repetisjon av viktigste mønstre og idiomer. [script →](./data.table/2024-04-22%20recap.data.table.R)
- `nafill()`, `setnafill()` — fylle ut manglende verdier i data.table. [script →](./data.table/2025-02-04%20data_table_fill.R)

---

## dplyr / tidyverse

Kjernen i tidyverse-arbeidsflyten: `filter`, `select`, `mutate`, `summarise` og reshape med tidyr.

- `left_join()`, `right_join()`, `full_join()` — joins i dplyr med nøkkel, suffiks og håndtering av duplikater. [script →](./dplyr/2022-12-21%20join.R)
- `across()`, `.by`, `consecutive_id()` — nyheter i dplyr 1.1.0; transformer flere kolonner og grupper uten `group_by`. [script →](./dplyr/2023-01-18%20dplyr_1_1_0.R)
- `filter()`, `mutate()`, `select()` — komplett rensingsworkflow: koding, filtrering og variabelkonstruksjon. [script →](./dplyr/2023-01-18%20example_data_cleaning.R)
- `pivot_longer()`, `pivot_wider()` — omforming mellom langt og bredt format med tidyr. [script →](./dplyr/2024-09-10%20from_long_to_wide.R)
- `coalesce()`, `case_when()`, `str_detect()` — samling av nyttige tidyverse-funksjoner for datarensing. [script →](./dplyr/2025-01-02%20tidyverse_useful_functions.R)
- `mutate(across(...))` — transformer flere kolonner samtidig med lambda-funksjoner for raskere kode. [script →](./dplyr/2024-08-19%20fast_multi_mutate.R)
- Ytelse: funksjonell vs dplyr — sammenligner kjøretid på typiske datahåndteringsoperasjoner. [script →](./dplyr/2025-04-11%20speed_functional_dplyr.R)

---

## Base R

Innebygde R-funksjoner uten pakker — nyttig for portabilitet, ytelse og å forstå hva pakkene gjør under panseret.

- R 4.4-nyheter — nye innebygde funksjoner som matcher dplyr- og data.table-funksjonalitet. [script →](./BaseR/new_feature_4.4.R)
- `aggregate()`, `tapply()` — group by i Base R uten pakker; sammenligning med dplyr. [script →](./BaseR/base_version_group_by.R)
- `tinyplot()` — lett plottepakke med samme syntaks som `plot()` men med ggplot2-inspirert output. [script →](./BaseR/2024-06-24%20tinyplot_intro.R)

### Strenger

- `strsplit()` — del opp tekststrenger etter separator; vanlige mønstre og edge cases. [script →](./BaseR/2024-05-13%20string_splitting.R)
- `gsub()`, `grepl()`, `regmatches()` — regulære uttrykk i Base R: søk, erstatt og ekstraher delstrenger. [script →](./BaseR/2022-08-26%20string_and_regex.R)

---

## Regression

`fixest`-pakken er R-standarden for faste effekter og instrumentvariabler — raskere enn `lm()` og med bedre tabelleksport.

- `feols()` — introduksjon til fixest: syntaks, faste effekter og tolkning av koeffisienter. [script →](./regression/2022-11-02%20fixest.R)
- `feols()`, `fepois()`, `etable()` — Poisson-regresjon, clustrede standardfeil og tabelloppsett. [script →](./regression/2022-11-03%20fixest_extra.R)
- `feols(fm = ...)` — spesifiser modeller programmatisk med fm-argumentet for iterasjon over spesifikasjoner. [script →](./regression/feols_fm_argument.R)

---

## Visualization

`ggplot2` med tillegg for kart, interaktivitet og base R-alternativer.

- `geom_sf()`, `ggplot2` — kartvisualisering med sf; norske fylker fargelagt etter variabel. [script →](./visualization/2022-08-26%20kart_fra_magne.R)
- Fargepaletter i RStudio Graphics — rask gjennomgang av paletter og hvordan de ser ut i RStudio-vinduet. [script →](./visualization/2023-01-18%20test_farge_grapichs_rstudio.R)
- `ggplot2` — ferdig figur med tema, farger og tekst tilpasset presentasjon for fagforening. [script →](./visualization/2023-02-17%20figur_til_fagforreningen.R)
- `plotly` — interaktive figurer med hover, zoom og animasjon; konvertering fra ggplot2. [script →](./visualization/ploty.R)
- `ggplot2` — tidsserieplot av regelverksendringer med annotasjoner for minstesats uføre. [script →](./visualization/2024-09-26%20illustrasjon_%C3%B8kning_minstesats_ufor.R)

---

## Shiny

Interaktive webapper i R. Starter enkelt med ett input/output og bygger mot reaktive oppsett.

- Enkel Shiny-app — minimal app med input og output; grunnstrukturen `ui` / `server`. [script →](./shiny/enkelt_example_shiny.R)
- `selectInput()`, `renderPlot()` — dropdown-input kobler til ggplot2-figur som oppdateres reaktivt. [script →](./shiny/2023-03-22%20shiny_app_figur_med_nedtrekksvalg.R)
- `fluidPage()` — fleksibelt sideoppsett med paneler og kolonner. [script →](./shiny/2023-11-06%20shiny_fuid.R)

---

## Time series

Tidsserieanalyse fra innlesing og dekomponering til ARIMA-modellering og framskrivning.

- `ts()`, `decompose()` — innlesing, visualisering og dekomponering av tidsserier i trend, sesong og residual. [script →](./timeseries/2023-10-08%20time_series_data.R)
- `auto.arima()`, `forecast()` — automatisk modellvalg og fremskrivning med `forecast`-pakken. [Quarto →](./timeseries/ARIMA%20modeling.qmd)
- Tidsserier i Quarto — komplett Quarto-rapport med tidsserieanalyse, figurer og tolkning. [Quarto →](./timeseries/timeseries.qmd)

---

## Quarto

Quarto er etterfølgeren til R Markdown — støtter HTML, PDF, Word, revealjs og Shiny i samme format.

- Quarto presentasjon — revealjs-presentasjon med temaoppsett, kodeblokker og fragmenter. [Quarto →](./quarto/presQuarto.qmd)
- Quarto + Shiny — kombiner Quarto med interaktive Shiny-komponenter i samme dokument. [Quarto →](./quarto/quarto_shiny_test1.qmd)
- Artikkelmal — akademisk artikkelformat med referanser, figurer og kryssreferanser. [Quarto →](./quarto/article%20template.qmd)
- shinyCH — Quarto-dokument med Shiny-server for interaktiv datautforskning. [Quarto →](./quarto/shinyCH.qmd)

---

## Analysis / Cases

Anvendte analyser på norske velferdsdata — NAV-registre, befolkningsstatistikk og policy-case.

- Uføretrygd, NAV.no — henter og strukturerer offentlige NAV-data om uføretrygd etter alder og år. [script →](./analysis/2024-04-17%20uttrekk_nav.no_uforetrygd.R)
- Helserelaterte data — prosessering av helserelaterte registreringer med dplyr og reshape. [script →](./analysis/2024-07-09%20helserelaterte_data_fraOla.R)
- Finne personer ved maxtid sykmeldt — identifiser individer som når makstid for sykemelding i registerdata. [script →](./analysis/2025-01-17%20finne_personer_maxtid_syk.R)
- Overgang ved maxtid syk — hva skjer etter makstid? Kartlegger overgang til andre ytelser. [script →](./analysis/2025-01-17%20overgang_maxtid_syk.R)
- Pensjonsforliket og innvandring — analyserer sammenheng mellom pensjonssystemet og innvandringsbakgrunn. [script →](./analysis/2024-10-16%20pensjonsforliket_invandring.R)
- EU60 og minstesatser — sammenligner norske minstesatser mot EU60-fattigdomsgrensen. [script →](./analysis/2024-10-18%20EU60_og_minstesatser.R)
- Beregningsgrunnlag ramme — setter opp beregningsrammer for ytelsesberegninger. [script →](./analysis/2024-11-20%20beregningsgrunnlag_ramme.R)
- Case uføre — sammensatt uttrekk og beregning rundt uføretrygd. [script →](./analysis/2025-04-08%20case_ufore.R)
- Prep data for matching — klargjør data for propensity score matching. [script →](./analysis/2025-02-12%20prep_data_for_matching.R)
- Google Analytics case — henter og analyserer netttrafikk-data fra Google Analytics API. [script →](./analysis/2025-01-25%20case_google_analytics.R)
- Simulerte data — generer syntetiske datasett for testing og metodedemonstrasjoner. [script →](./analysis/2023-03-14%20sim_data.R)

---

## Textanalysis

Tekstanalyse i tidy-format med `tidytext` — tokenisering, ordfrekvenser og TF-IDF.

- `unnest_tokens()`, `anti_join()` — tokenisering, stoppordfiltrering og ordfrekvenser; grunnleggende tidytext-arbeidsflyt. [script →](./Textanalysis/intro_text_as_data.R)
- `bind_tf_idf()` — TF-IDF for å finne karakteristiske ord per gruppe og forberede data for modellering. [script →](./Textanalysis/token_and_prepering.R)

---

## File management

Filhåndtering med `fs`-pakken og `purrr` — iterasjon over filer, feilhåndtering og pipeline-mønstre.

- `dir_ls()`, `file_copy()`, `file_move()` — kryssplattform filhåndtering med `fs`: liste, kopiere og flytte filer. [script →](./filemanagement/2025-01-10%20file_management_fs.R)
- `safely()`, `possibly()` — innhyl funksjoner for å håndtere feil uten å stoppe kjøringen; inspiser resultater etterpå. [script →](./filemanagement/2025-01-13%20safely_purrr.R)
- `map()`, `feols()` — kjør regresjonsmodeller over grupper med `map()` for ryddigere og mer gjenbrukbar kode. [script →](./filemanagement/2025-01-14%20purrr_cleaner_code_reg_example.R)
