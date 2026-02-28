

library(tidyverse)
library(openxlsx)

#
df1 <- readxl::read_excel("data/2023-09-20 budsjett_data.xlsx") |> 
    mutate( ar = year(periode),
            periode = as.character(periode)) |> 
    select(periode, ar, mottakere, regnskap
           )

#
wb <- createWorkbook()
addWorksheet(wb, "Sheet1")
addWorksheet(wb, "Sheet2")

# Skriv mottakere
writeData(wb, "Sheet1", x = df1)

# 
ar <- c(2018:2022, ("2021-06-01"),("2022-06-01"),("2023-06-01") ) |> as.character()
i <- 2:(length(ar)+1)

df2 <- data.frame( ar = ar,
                   mottakere    = c(
                       paste0("AVERAGEIF(Sheet1!B:B,A",c(2:(length(ar)-2) ),",Sheet1!C:C)" ),
                       paste0("VLOOKUP(A",7:9,",Sheet1!A:C,3,FALSE)" )
                       ),
                   endring      = paste0("(B",i,"-B",(i-1),")" ),
                   prosentvekst = paste0("(B",(i-1),"/B",i,"-1)*100" ),
                   stringsAsFactors = FALSE
                   )

class(df2$mottakere) <- c(class(df2$mottakere), "formula")
class(df2$endring) <- c(class(df2$endring), "formula")
class(df2$prosentvekst) <- c(class(df2$prosentvekst), "formula")

writeData(wb, sheet = 2, x = df2)

saveWorkbook(wb, file = "data_export/test2.xlsx", overwrite = T)

#readxl::read_excel("data_export/test.xlsx", sheet = "statistikk")
readxl::read_excel("data_export/test2.xlsx", sheet = 2, skip = 0)





class(df$z) <- c(class(df$z), "formula")
class(df$z2) <- c(class(df$z2), "formula")
class(df$z3) <- c(class(df$z3), "formula")


df <- data.frame(
    x = 1:3,
    y = 1:3,
    i = 1:3,
    z = paste(paste0("A", 1:3 + 1L), paste0("B", 1:3 + 1L), sep = " + "),
    z2 = sprintf("ADDRESS(1,%s)", 1:3),
    z3 = paste0("SUM(A",2:4,":B",2:4, ")"),
    stringsAsFactors = FALSE
)
