

# from: https://stata2r.github.io/fixest/#installation
library(data.table)
library(fixest)
library(modelsummary)
library(stargazer)
library(tidyverse)

# data
cps <- data.table::fread('https://raw.githubusercontent.com/stata2r/stata2r.github.io/main/data/cps_long.csv')

#fwrite(cps, "data/cps.csv")
skimr::skim(cps)
hist(cps$wage)

# Base 
lm( data = cps, wage ~educ) |> summary() # alternativ |> modelsummary( models = _)

# fixest ols
feols( data = cps, wage ~educ)
feols( data = cps, wage ~educ + age) |> summary()

# categorical
feols( cps,  wage ~educ + treat)
feols( cps,  wage ~educ + i(treat))
feols( cps,  wage ~educ + i(treat, ref = 1)) # Categorical change report

lm( data = cps , wage ~ educ + treat )
lm( data = cps |> mutate( treat = fct_rev(factor(treat) )) , wage ~ educ + treat )



# # Fixed effect ----------------------------------------------------------

feols( data = cps, wage ~educ | countyfips + year)
feols( data = cps, wage ~educ | countyfips + year, vcov = "iid") #iid standard errors

lm( data = cps,
    wage ~educ + countyfips + year
)

# Equil this:
lm( data = cps,
    wage ~educ + I(factor(countyfips)) + I(factor(year))
) |> stargazer( keep = c("educ"), type = "text")



# IV ----------------------------------------------------------------------

#
lm( data = cps, wage ~1 )

estimatr::iv_robust( data = cps, wage ~ 1 + educ | age  ) |> summary( )
feols(cps, wage ~ 1 | educ ~age )

# The same
estimatr::iv_robust( data = cps, wage ~ marr + educ | age + marr ) |> summary( )
feols(cps, wage ~ marr | educ ~age )



# Non linear models -------------------------------------------------------

# logit models
cps
glm(data = cps,  marr ~ age + black + hisp, family = binomial("logit")) |> summary()

#  fixest
feglm( data = cps,  marr ~ age + black + hisp, family = "logit")

# Poisson regression
fepois( educ ~ age + black + hisp| statefips + year, data = cps)



# shortcuts ---------------------------------------------------------------

cont <- c("age", "black", "hisp", "marr")

feols(wage ~ educ + .[cont], data = cps)
feols(wage ~ educ + ..("^x"), data = cps)
feols(wage ~ educ + age, data = cps)



# Advance multi model estimation --------------------------------------------

feols( wage ~educ, data = cps[ treat == 1,,])
feols( wage ~educ, data = cps, split = ~treat) # split regression sample

# stepwise regression
# first dont include marr, second reg osv.
feols( wage ~ educ + sw(age, marr), data = cps)
feols( wage ~ educ + sw0(age, marr), data = cps)
feols( wage ~ educ + csw(age, marr), data = cps)
feols( wage ~ educ + csw0(age, marr), data = cps)


many_model <- accumulate(c("age", "marr", "black"), function(a,b) paste(a,b, sep = "+") )
models <- paste0("wage ~", many_model)
map( models, ~lm(formula = .x, data = cps))

feols( wage ~ csw(age,marr,black), data = cps)

## Fixed effect slot
feols( wage ~educ| csw(year, statefips), data = cps)


# Interactions and polynomic--------------------------------------------------------

feols(wage ~educ:age, cps)
feols(wage ~educ*age, cps)
feols( wage ~I(age^2), cps)
feols( wage ~poly(age, 4), cps)



# Diff-in-diff ------------------------------------------------------------

# data
url <- "https://raw.githubusercontent.com/DS4PS/pe4ps-textbook/master/data/diff-in-diff-housing-example.csv"

house <- fread(url) |> janitor::clean_names()
house

lm( data = house, house_price ~group + post_treatment + I(post_treatment*group))

house[, .( price = mean(house_price)/1000),by = .(group, post_treatment)][] |> dcast( group ~post_treatment)
(302-233)-(251-216)



# Standard errors ---------------------------------------------------------

# HC
feols(cps,  wage ~educ, vcov = "hc1")
feols(cps,  wage ~educ, vcov = sandwich::vcovHC)

# or
model <- feols(cps,  wage ~educ)
summary(model, vcov = "hc1")

# cluster
feols(cps,  wage ~educ, vcov = ~countyfips)

# twoways cluster
feols(cps,  wage ~educ, vcov = ~countyfips + year)

# conley st.ers
feols(wage ~educ, vcov = conley("25 mi"), cps)

### om the fly
model
summary(model, vcov = "iid")
summary(model, vcov = ~countyfips + year)


# Presentation ------------------------------------------------------------

etable(model)

# Add regression
model2 <- feols(cps,  wage ~educ + marr, vcov = ~countyfips + year)

etable( list(model, model2))
etable( list(model, model2),  file = "data_export/regtabele.tex")



# Coef-test ---------------------------------------------------------------

data.table::setnames(cps, c('black','hisp'), c('raceeth_black','raceeth_hisp'))

est1 <- feols( wage ~educ  + age + ..("raceeth_"), dat = cps)

wald( est1, c("raceeth_black", "raceeth_hisp"))
wald( est1, "raceeth")

coefplot(est1) |> str()

broom::tidy(est1) |> ggplot2::ggplot( aes(y = estimate , x = term) ) +
    geom_errorbar(aes(ymin = estimate - std.error*1.96,
                      ymax = estimate + std.error*1.96)
    ) |> str()



# interaction plot
data.table::setnames(cps,  c('raceeth_black','raceeth_hisp'),c('black','hisp'))

est1 <- feols( wage ~i(hisp, age), data = cps)

iplot(est1)

library(marginaleffects)

plot_m <- plot_cap(est1, condition = c("age", "hisp"))
class(plot_m)


# Panel
feols( wage ~educ + l(wage,1), cps, panel.id = ~id+year)

# First diff
feols(wage ~educ + d(wage), data = cps)





























