
# fixest — rask og fleksibel regresjon i R
#
# Gjennomgang av fixest-pakken: OLS, faste effekter, IV, ikke-lineære
# modeller, standardfeil, presentasjon og interaksjoner.
# Basert på: https://stata2r.github.io/fixest/#installation
#
# Datasett: Current Population Survey (CPS) — individdata med loenn,
# utdanning, alder, sivilstatus, rase og geografi.

library(data.table)
library(fixest)
library(modelsummary)
library(stargazer)
library(tidyverse)

# 1. Data -----------------------------------------------------------------

cps <- data.table::fread('https://raw.githubusercontent.com/stata2r/stata2r.github.io/main/data/cps_long.csv')

#fwrite(cps, "data/cps.csv")
skimr::skim(cps)
hist(cps$wage)

# 2. OLS — grunnleggende regresjon ----------------------------------------

# Base R: lm() gir samme resultat som feols(), men feols() er raskere
# og har bedre integrasjon med faste effekter og klustrede standardfeil.
lm( data = cps, wage ~educ) |> summary() # alternativ |> modelsummary( models = _)

# feols() er fixest sin OLS-funksjon
feols( data = cps, wage ~educ)
feols( data = cps, wage ~educ + age) |> summary()

# 3. Kategoriske variabler ------------------------------------------------

# Uten i(): treat tolkes som kontinuerlig (en koeffisient)
feols( cps,  wage ~educ + treat)

# Med i(): treat tolkes som faktor — en dummy per kategori
feols( cps,  wage ~educ + i(treat))

# ref = 1: bruker treat == 1 som referansekategori (utelatt fra regresjonen)
feols( cps,  wage ~educ + i(treat, ref = 1))

# Samme logikk i base R — man maa eksplisitt gjore treat til faktor
lm( data = cps , wage ~ educ + treat )
lm( data = cps |> mutate( treat = fct_rev(factor(treat) )) , wage ~ educ + treat )


# 4. Faste effekter -------------------------------------------------------

# Pipe-syntaks: variabler etter | er faste effekter.
# fixest absorberer dem (demean) — de rapporteres ikke i output.
# Default standardfeil: klustret paa foerste FE-variabel (countyfips).
feols( data = cps, wage ~educ | countyfips + year)

# vcov = "iid": vanlige (ikke-klustrede) standardfeil
feols( data = cps, wage ~educ | countyfips + year, vcov = "iid")

# lm()-ekvivalent: her inkluderes FE som vanlige koeffisienter —
# fungerer, men er tregt paa store data og gir lang output
lm( data = cps,
    wage ~educ + countyfips + year
)

# I(factor(...)): tvinger lm() til aa behandle numeriske variabler som faktorer.
# stargazer(keep = "educ"): viser kun educ-koeffisienten (skjuler alle FE-dummyer)
lm( data = cps,
    wage ~educ + I(factor(countyfips)) + I(factor(year))
) |> stargazer( keep = c("educ"), type = "text")


# 5. Instrumentvariabler (IV / 2SLS) -------------------------------------

# IV-regresjon: educ er endogen, instrumenteres med age.
# Syntaks: wage ~ eksogene | endogen ~ instrument
# "wage ~ 1" betyr ingen eksogene kontrollvariabler (kun konstantledd).

lm( data = cps, wage ~1 )

# estimatr::iv_robust() — alternativ pakke for IV med robuste standardfeil
estimatr::iv_robust( data = cps, wage ~ 1 + educ | age  ) |> summary( )

# fixest IV-syntaks: utfall ~ eksogene | endogen ~ instrument
# Her: wage ~ 1 | educ ~ age  (educ instrumentert med age)
feols(cps, wage ~ 1 | educ ~age )

# Med eksogen kontrollvariabel (marr):
# wage ~ marr | educ ~ age  (marr er eksogen, educ instrumentert med age)
estimatr::iv_robust( data = cps, wage ~ marr + educ | age + marr ) |> summary( )
feols(cps, wage ~ marr | educ ~age )


# 6. Ikke-lineaere modeller -----------------------------------------------

# Logistisk regresjon: binaert utfall (marr = gift/ikke gift)
# glm() med family = binomial("logit") er base R-versjonen
glm(data = cps,  marr ~ age + black + hisp, family = binomial("logit")) |> summary()

# feglm(): fixest sin logit — stoetter faste effekter i tillegg
feglm( data = cps,  marr ~ age + black + hisp, family = "logit")

# Poisson-regresjon: for telledata (educ = antall aar utdanning)
# Stoetter faste effekter direkte (statefips + year)
fepois( educ ~ age + black + hisp| statefips + year, data = cps)


# 7. Snarveier for variabelseleksjon -------------------------------------

# .[cont]: setter inn en vektor av variabelnavn i formelen
cont <- c("age", "black", "hisp", "marr")
feols(wage ~ educ + .[cont], data = cps)

# ..("regex"): velger alle variabler som matcher et regulaert uttrykk
# Her: alle kolonner som starter med "x"
feols(wage ~ educ + ..("^x"), data = cps)

feols(wage ~ educ + age, data = cps)


# 8. Multimodell-estimering -----------------------------------------------

# Kjoer regresjon paa et subsett
feols( wage ~educ, data = cps[ treat == 1,,])

# split: kjoer separate regresjoner per gruppe (her: per treat-verdi)
feols( wage ~educ, data = cps, split = ~treat)

# sw(), sw0(), csw(), csw0() — trinnvis inkludering av variabler:
#   sw():   bytter mellom variabler    (educ+age, educ+marr)
#   sw0():  som sw() men ogsaa uten    (educ, educ+age, educ+marr)
#   csw():  kumulativ — legger til     (educ+age, educ+age+marr)
#   csw0(): som csw() men ogsaa uten   (educ, educ+age, educ+age+marr)
feols( wage ~ educ + sw(age, marr), data = cps)
feols( wage ~ educ + sw0(age, marr), data = cps)
feols( wage ~ educ + csw(age, marr), data = cps)
feols( wage ~ educ + csw0(age, marr), data = cps)

# Samme logikk bygget manuelt med accumulate() og map()
many_model <- accumulate(c("age", "marr", "black"), function(a,b) paste(a,b, sep = "+") )
models <- paste0("wage ~", many_model)
map( models, ~lm(formula = .x, data = cps))

# csw() gjor det samme paa en linje
feols( wage ~ csw(age,marr,black), data = cps)

# csw() fungerer ogsaa i FE-slotten: legger til faste effekter trinnvis
feols( wage ~educ| csw(year, statefips), data = cps)


# 9. Interaksjoner og polynomer ------------------------------------------

# educ:age  — kun interaksjonsleddet (ikke hovedeffektene)
feols(wage ~educ:age, cps)

# educ*age  — hovedeffekter + interaksjon (educ + age + educ:age)
feols(wage ~educ*age, cps)

# I(age^2)  — kvadratisk ledd (andregradspolynom)
feols( wage ~I(age^2), cps)

# poly(age, 4) — fjerdegradspolynom (ortogonale polynomer som default)
feols( wage ~poly(age, 4), cps)


# 10. Difference-in-differences -------------------------------------------

# Klassisk 2x2 DiD: sammenligner behandlings- og kontrollgruppe
# foer og etter en intervensjon.

url <- "https://raw.githubusercontent.com/DS4PS/pe4ps-textbook/master/data/diff-in-diff-housing-example.csv"
house <- fread(url) |> janitor::clean_names()
house

# DiD med lm(): interaksjonsleddet (post_treatment * group) er DiD-estimatet
lm( data = house, house_price ~group + post_treatment + I(post_treatment*group))

# Manuell sjekk: beregn gjennomsnittspris per gruppe/periode
house[, .( price = mean(house_price)/1000),by = .(group, post_treatment)][] |> dcast( group ~post_treatment)

# DiD = (behandling etter - behandling foer) - (kontroll etter - kontroll foer)
(302-233)-(251-216)


# 11. Standardfeil --------------------------------------------------------

# fixest gjor det enkelt aa bytte mellom standardfeiltyper —
# enten direkte i feols() eller i ettertid med summary().

# HC1 (heteroskedastisitetsrobuste, "White's standardfeil")
feols(cps,  wage ~educ, vcov = "hc1")
feols(cps,  wage ~educ, vcov = sandwich::vcovHC)

# Bytte standardfeil i ettertid — modellen estimeres kun en gang
model <- feols(cps,  wage ~educ)
summary(model, vcov = "hc1")

# Klustrede standardfeil: tar hensyn til korrelasjon innen grupper
feols(cps,  wage ~educ, vcov = ~countyfips)

# Toveisklustrede: korrelasjon bade innen fylke og innen aar
feols(cps,  wage ~educ, vcov = ~countyfips + year)

# Conley: romlig korrelasjon innen 25 miles (krever koordinater i data)
feols(wage ~educ, vcov = conley("25 mi"), cps)

# "On the fly" — samme modell, ulike standardfeil uten re-estimering
model
summary(model, vcov = "iid")
summary(model, vcov = ~countyfips + year)


# 12. Presentasjon med etable() -------------------------------------------

# etable(): fixest sin tabell-funksjon — lager pene regresjonstabeller
etable(model)

# Flere modeller side om side
model2 <- feols(cps,  wage ~educ + marr, vcov = ~countyfips + year)
etable( list(model, model2))

# Eksporter til LaTeX
etable( list(model, model2),  file = "data_export/regtabele.tex")


# 13. Koeffisienttest (Wald-test) -----------------------------------------

# Wald-test: tester om en gruppe koeffisienter er simultant lik null.
# Nyttig for aa teste om en hel kategori (f.eks. rase) er signifikant.

data.table::setnames(cps, c('black','hisp'), c('raceeth_black','raceeth_hisp'))

est1 <- feols( wage ~educ  + age + ..("raceeth_"), dat = cps)

# Test enkeltkoeffisienter
wald( est1, c("raceeth_black", "raceeth_hisp"))

# Shortcut: matcher alle koeffisienter som inneholder "raceeth"
wald( est1, "raceeth")

# coefplot(): visuell fremstilling av koeffisienter med konfidensintervall
coefplot(est1) |> str()

# Alternativ med broom + ggplot2 for mer kontroll over plottet
broom::tidy(est1) |> ggplot2::ggplot( aes(y = estimate , x = term) ) +
    geom_errorbar(aes(ymin = estimate - std.error*1.96,
                      ymax = estimate + std.error*1.96)
    ) |> str()


# 14. Interaksjonsplot ----------------------------------------------------

data.table::setnames(cps,  c('raceeth_black','raceeth_hisp'),c('black','hisp'))

# i(hisp, age): interaksjon der hisp er faktor og age er kontinuerlig
est1 <- feols( wage ~i(hisp, age), data = cps)

# iplot(): plotter koeffisientene fra i()-interaksjoner
iplot(est1)

# marginaleffects: mer avanserte marginale effektplott
library(marginaleffects)
plot_m <- plot_cap(est1, condition = c("age", "hisp"))
class(plot_m)


# 15. Paneldata — lag og foerstedifferanse --------------------------------

# l(wage, 1): lagget variabel — wage fra forrige periode (year - 1)
# Krever panel.id som identifiserer individ (id) og tid (year)
feols( wage ~educ + l(wage,1), cps, panel.id = ~id+year)

# d(wage): foerstedifferanse — endring i wage fra forrige periode
feols(wage ~educ + d(wage), data = cps)
