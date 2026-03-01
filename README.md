# Collection of different scripts and coding concepts

## Innhold
| # | Tema | Beskrivelse |
|---|------|-------------|
| 1 | [Small smart coding parts](#small-smart-coding-parts) | Nyttige enkeltfunksjoner og triks |
| 2 | [API and query](#api-and-query) | SSB API og datauttak |
| 3 | [Functional / Iteration](#functional--iteration) | map, walk, apply, reduce |
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

## Small smart coding parts
- [`expand_grid()` - combining numbers and intervals](./BaseR/expand_grid_test.R)
- [The `quantile()` function and grouping by quantile cuts](./analysis/quantile_function.R)
- [datapasta - paste data into R](./BaseR/datapasta.R)

## API and query
- [SSB API - befolkningsdata](./api/api_ssb_befolkning.R): Demografiske data over Norges befolkning (07459: Befolkning, etter kjønn, alder, statistikkvariabel og år)
- [SSB befolkningsframskrivning fylkesvis](./api/ssb_befolkningframskrivning_fylkesvis.R)
- [Faktisk befolkning, fylkesvis og aldersgrupper](./api/faktisk_befolkning_fylkesvis_aldersgrupper.R)
- [Befolkningsframskrivning](./api/befolkningsframskrivning.R)

## Functional / Iteration
- [Iteration over rows and columns (`apply()` and `for` loops)](./iterate/2025-01-08%20iteration_column_or_rows.R)
- [purrr-recap: `keep()` and `discard()`](./iterate/2025-01-08%20purrr_predicate.R)
- [`negate()` and `compose()` for minimal code](./iterate/2025-01-15%20purrr_negate_compose_partial.R)
- [Base R and the apply-family](./iterate/apply_family.R)
- [Functional programming - functional.R (2022-09)](./iterate/2022-09-01%20functional.R)
- [purrr - keep, discard and list](./iterate/2025-01-16%20keep_discard_and_list.R)
- [recap: `accumulate()`](./iterate/recap_accumulate.R)
- [accumulate function](./iterate/accumlate_function.R)

## R and Excel
- [openxlsx - basic example](./excel/openxl.R)
- [openxlsx - advanced example](./excel/openxl_example2.R)
- [Eksportere tabeller til Excel](./excel/ex_openexcel.R)
- [Budsjett tabeller til Excel](./excel/budsjett_tabeller_til_Excel.R)
- [Importere tabell med tekst](./excel/import_tabell_med_tekst.R)

## Data.table
- [Basic concepts of data.table](./data.table/2022-08-17%20data.table.R)
- [data.table by needs](./data.table/2022-08-31%20data.table_by_needs.R)
- [data.table - Grant McDermott](./data.table/2022-10-18%20data.table_grant_mcdermott.R)
- [data.table concepts](./data.table/2022-11-22%20data.table_consepts.R)
- [Collapsing strings](./data.table/2024-05-13%20collapsing_strings.R)
- [Timing data.table vs dplyr](./data.table/2022-11-14%20timeing_data.table_dplyr.R)
- [Recap data.table](./data.table/2024-04-22%20recap.data.table.R)
- [data.table fill](./data.table/2025-02-04%20data_table_fill.R)

## dplyr / tidyverse
- [joins](./dplyr/2022-12-21%20join.R)
- [dplyr 1.1.0 nyheter](./dplyr/2023-01-18%20dplyr_1_1_0.R)
- [Eksempel datarensing](./dplyr/2023-01-18%20example_data_cleaning.R)
- [Long to wide](./dplyr/2024-09-10%20from_long_to_wide.R)
- [Tidyverse useful functions](./dplyr/2025-01-02%20tidyverse_useful_functions.R)
- [Fast multi mutate](./dplyr/2024-08-19%20fast_multi_mutate.R)
- [Speed: functional vs dplyr](./dplyr/2025-04-11%20speed_functional_dplyr.R)

## Base R
Highlights important verbs and solutions in Base R.
- [News for R 4.4 - comparable to dplyr and data.table](./BaseR/new_feature_4.4.R)
- [Group by - base R versjon](./BaseR/base_version_group_by.R)
- [tinyplot - Base R plotting](./BaseR/2024-06-24%20tinyplot_intro.R)

### Handling strings
- [String splitting with `strsplit()`](./BaseR/2024-05-13%20string_splitting.R)
- [String and regex](./BaseR/2022-08-26%20string_and_regex.R)

## Regression
- [fixest intro](./regression/2022-11-02%20fixest.R)
- [fixest extra](./regression/2022-11-03%20fixest_extra.R)
- [feols `fm` argument](./regression/feols_fm_argument.R)

## Visualization
- [Kart (ggplot)](./visualization/2022-08-26%20kart_fra_magne.R)
- [Test farger i RStudio graphics](./visualization/2023-01-18%20test_farge_grapichs_rstudio.R)
- [Figur til fagforeningen](./visualization/2023-02-17%20figur_til_fagforreningen.R)
- [Plotly](./visualization/ploty.R)
- [Illustrasjon økning minstesats uføre](./visualization/2024-09-26%20illustrasjon_%C3%B8kning_minstesats_ufor.R)

## Shiny
- [Enkel Shiny-app](./shiny/enkelt_example_shiny.R)
- [Shiny app med nedtrekksvalg](./shiny/2023-03-22%20shiny_app_figur_med_nedtrekksvalg.R)
- [Shiny fluid](./shiny/2023-11-06%20shiny_fuid.R)

## Time series
- [Time series data](./timeseries/2023-10-08%20time_series_data.R)
- [ARIMA modeling](./timeseries/ARIMA%20modeling.qmd)
- [Time series - Quarto](./timeseries/timeseries.qmd)

## Quarto
- [Quarto presentasjon](./quarto/presQuarto.qmd)
- [Quarto + Shiny](./quarto/quarto_shiny_test1.qmd)
- [Article template](./quarto/article%20template.qmd)
- [shinyCH](./quarto/shinyCH.qmd)

## Analysis / Cases
- [Uføretrygd - uttrekk NAV.no](./analysis/2024-04-17%20uttrekk_nav.no_uforetrygd.R)
- [Helserelaterte data](./analysis/2024-07-09%20helserelaterte_data_fraOla.R)
- [Finne personer ved maxtid syk](./analysis/2025-01-17%20finne_personer_maxtid_syk.R)
- [Overgang maxtid syk](./analysis/2025-01-17%20overgang_maxtid_syk.R)
- [Pensjonsforliket og innvandring](./analysis/2024-10-16%20pensjonsforliket_invandring.R)
- [EU60 og minstesatser](./analysis/2024-10-18%20EU60_og_minstesatser.R)
- [Beregningsgrunnlag ramme](./analysis/2024-11-20%20beregningsgrunnlag_ramme.R)
- [Case uføre](./analysis/2025-04-08%20case_ufore.R)
- [Prep data for matching](./analysis/2025-02-12%20prep_data_for_matching.R)
- [Google Analytics case](./analysis/2025-01-25%20case_google_analytics.R)
- [Sim data](./analysis/2023-03-14%20sim_data.R)

## Textanalysis
- [Introduction to basic concepts](./Textanalysis/intro_text_as_data.R): `unnest_tokens(word, review)` og tidytext
- [Tokens and preparing data](./Textanalysis/token_and_prepering.R)

## File management
- The [`fs` package](https://fs.r-lib.org/) for file management: [example](./filemanagement/2025-01-10%20file_management_fs.R)
- [Safely with purrr](./filemanagement/2025-01-13%20safely_purrr.R)
- [purrr - cleaner code regression example](./filemanagement/2025-01-14%20purrr_cleaner_code_reg_example.R)
