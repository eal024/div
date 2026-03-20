# Manus — Lesbare R-skript med tidyverse

> **Totalt: ~40 min** | Tidsanslag per slide i parentes

---

## Tittelslide *(0 min)*

- Si navn og introduser tema kort
- "I dag ser vi på hvordan vi skriver R-kode som er lett å lese — for andre, og for deg selv"

---

## Du åpner et skript fra i fjor *(2 min)*

- Pek på venstre kolonne: "Kjenner dere igjen dette? Variabelnavn som V1, V2, V3. Ingen kommentarer. Hva gjør dette skriptet?"
- "Det er ikke R som er problemet — det er at skriptet ikke kommuniserer noe"
- Pek på høyre kolonne: "Samme operasjon. Men nå kan du lese det som en setning: behold gyldige rader, lag en ny variabel, sammenfatt per gruppe"
- "Det er dette vi skal jobbe mot i dag"

---

## tidyverse — én arbeidsflyt strukturerer alt *(2 min)*

- "Tidyverse er ikke én pakke — det er en samling verktøy bygget rundt én felles arbeidsflyt"
- Pek på boksene: "Import → Tidy → Transform/Visualize/Model → Communicate. Alle prosjekter følger denne flyten, uansett størrelse"
- Pek på terracotta-heksene: "dplyr, stringr, forcats, lubridate — disse bruker vi til Transform"
- "I dag fokuserer vi på dplyr, og vi ser på noen prinsipper for lesbar kode"

---

## Palmer Penguins — datasettet vi bruker i dag *(1.5 min)*

- "Vi bruker Palmer Penguins — 344 pingviner, 3 arter, 3 øyer i Antarktis"
- Pek på tabellen: "Seks variabler: art, øy, nebbmål, finnemål og kroppsmasse"
- "Dere kjenner sikkert iris-datasettet — dette er det moderne alternativet. Lett å forstå, men likevel nok til å vise alle teknikkene vi trenger"

---

## dplyr gir deg seks verb for å transformere data *(2 min)*

- "dplyr handler om seks verb. Lærer du disse seks, kan du gjøre det meste"
- Gå gjennom kortene raskt: "filter — velge rader. select — velge kolonner. mutate — lage nye variabler. summarise — aggregere. group_by — gruppert analyse. arrange — sortere"
- "Legg merke til at de alle er verb — handlinger. Det gjør koden lesbar som engelsk"
- "Vi skal nå se disse i bruk"

---

## 5 tips for lesbare skript *(1 min)*

- "Etter kode-demoen går vi over til fem konkrete tips du kan ta i bruk med en gang"
- Les opp listen raskt — bare navnene, ikke forklaringene
- "La oss starte med pipe"

---

## filter() beholder kun gyldige rader *(3 min)*

- "Pipe-operatoren `|>` er det viktigste enkelttegnet i tidyverse. Den leser du som 'og så'"
- Les koden høyt: "Ta penguins — og så — behold rader der bill_length_mm ikke er NA"
- Pek på tabellen: "333 av 344 rader beholdes. 11 hadde manglende nebbmål"
- "Uten pipe: `filter(penguins, !is.na(bill_length_mm))` — da leser du innenfra og ut. Med pipe leser du ovenfra og ned, som en oppskrift"

---

## mutate() legger til uten å slette *(3 min)*

- "mutate legger til en ny kolonne — og beholder alle de andre"
- Pek på koden: "Vi beregner ratio — nebbets lengde delt på dybde — for hver pingvin"
- Pek på tabellen: "Se at species, bill_length og bill_depth fortsatt er der — vi har bare lagt til ratio"
- "Dette er viktig: mutate destruerer ikke data. Du kan alltid se hva som ble gjort"

---

## summarise() komprimerer til ett tall per gruppe *(3 min)*

- "Nå setter vi det hele sammen. Les koden fra topp til bunn"
- Les høyt: "Ta penguins — filtrer bort NA — lag ratio — summer per art"
- Pek på resultatet: "344 rader blir til 3 rader. Én rad per art"
- "Dette er styrken med pipe: du ser hele analysen i én sekvens. Ingen mellomlagringer, ingen løkker"
- "`.by = species` er den moderne måten å gruppere på — erstatter `group_by()` etterfulgt av `ungroup()`"

---

## mutate() er åpen for hele R — også stringr og forcats *(2 min)*

- "mutate er ikke begrenset til regneoperasjoner. Du kan bruke hvilken som helst funksjon inne i mutate"
- Pek på `str_detect`: "Fra stringr — søker i tekst. Her lager vi en logisk variabel: er dette en Gentoo-pingvin?"
- Pek på `fct_other`: "Fra forcats — slår sammen faktor-nivåer. Adelie og Chinstrap blir 'Other'"
- "Kommentarene med `#` forklarer hva som skjer — vi kommer tilbake til det"

---

## 02 — Lesbar og reproduserbar kode *(0.5 min)*

- "Nå går vi over til de fem tipsene. Disse handler ikke om hvilke funksjoner du bruker — men hvordan du organiserer arbeidet"

---

## 2. Én mappe per prosjekt — aldri setwd() *(3 min)*

- Pek på treet: "Én rotkatalog per prosjekt. Data inn i `data/`, kode i `kode/`, eksport i `data_export/`"
- "Hvorfor? Fordi `setwd('C:/Users/eirik/Documents/...')` bare fungerer på din maskin. Kollegaen din får feil når hun åpner skriptet"
- Pek på `here::here()`: "her-pakken finner alltid prosjektmappen, uansett hvem som kjører skriptet og på hvilken maskin"
- "Bruk RStudio-prosjekter — `.Rproj`-filen setter automatisk arbeidsmappen riktig"

---

## 3. Seksjonsoverskrifter gjør skriptet navigerbart *(3 min)*

- Pek på kodeblokken: "Et skript uten struktur er som en bok uten kapitler"
- "Dobbel `##` med strekene etterpå — RStudio viser disse i Outline-panelet til høyre"
- Pek på key-box: "Hurtigtasten `Ctrl+Shift+R` setter inn overskriften automatisk — dere trenger ikke skrive strekene for hånd"
- "Se på eksemplet: Import, Data rens, Export. Tre seksjoner — en leser forstår strukturen uten å lese en eneste kodelinje"

---

## 4. Forklar hvorfor, ikke hva *(3 min)*

- Pek på venstre kolonne: "Disse kommentarene er ubrukelige. `# Filtrer rader` — det ser jeg at du gjør. `# Lag ny variabel` — det ser jeg også"
- Pek på høyre kolonne: "Disse er nyttige. `# Ekskluder mindreårige (jf. protokoll)` — nå vet jeg *hvorfor* vi filtrerer. `# 2 = kvinner (SSB-koding)` — uten dette husker ingen hva 2 betyr om seks måneder"
- "Koden viser hva som skjer. Kommentaren forklarer hvorfor det skjer"
- "Nummerkoder skal alltid forklares — det er en absolutt regel"

---

## 5. Kopiert kode er teknisk gjeld *(3 min)*

- Pek på venstre kolonne: "Kjenner dere igjen dette mønsteret? Man kopierer kode og endrer ett ord"
- "Problemet: når du finner en feil, må du fikse den fem steder. Og du glemmer alltid ett"
- Pek på høyre kolonne: "Løsningen er en funksjon. Skriv én gang, bruk mange ganger"
- "Tommelfingerregelen: kopierer du kode mer enn to ganger — skriv en funksjon"
- "Dette er ikke avansert programmering. Det er det viktigste steget fra å skrive kode til å skrive *god* kode"

---

## Lesetips *(2 min)*

- Pek på R for Data Science: "Dette er den beste boken for å komme i gang med tidyverse. Gratis online. Dere trenger ikke lese den fra perm til perm — bruk den som oppslagsverk"
- Pek på Cheat Sheets: "Posit lager én-sides referansekort for hver pakke. Print ut dplyr og tidyr og heng dem på veggen"
- Pek på Style Guide: "Hadley Wickhams stilguide — navngiving, innrykk, pipes. Følger du denne er koden din gjenkjennelig for alle som kan tidyverse"

---

## tidyverse er ikke alltid svaret *(3 min)*

- "Jeg vil være ærlig: tidyverse er ikke perfekt"
- Pek på hastighet: "På store datasett — millioner av rader — kan dplyr være treg. `data.table` er et alternativ som kan gi 10–100 ganger bedre ytelse"
- Vis kodeeksemplet: "Syntaksen er annerledes, men konseptet er det samme"
- "dtplyr er en bro mellom de to — du skriver dplyr-syntaks, men kjøringen skjer i data.table"
- Pek på avhengigheter: "tidyverse trekker med seg 30+ pakker. Greit for analyse, men problematisk hvis du lager en R-pakke selv eller jobber i et kontrollert produksjonsmiljø"
- "Rådet: start med tidyverse. Bytt til data.table når du faktisk har et ytelsesbehov"

---

## Ta det med deg *(1 min)*

- "Én konkret ting å gjøre i dag — ikke i morgen, i dag:"
- Les opp: "Åpne et skript du har skrevet. Legg til én seksjonsoverskrift med Ctrl+Shift+R"
- "Det tar 30 sekunder. Og neste gang du åpner skriptet, vet du akkurat hva som er hvor"
- Takk for oppmerksomheten — åpne for spørsmål

---

> **Tidsoversikt:**
> Åpning (slide 2–5): ~8 min
> Pipe-demo (slide 6–10): ~13 min
> 5 tips (slide 11–15): ~13 min
> Avslutning (slide 16–18): ~6 min
> **Total: ~40 min**
