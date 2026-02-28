
library(tidyverse)

data <-  readxl::read_excel("data/Case - uføretrygd.xlsx", sheet = 2) |> rename( index = 1, ufore = 2, inntekt = 3)

hist(data$inntekt[data$inntekt > 0])
