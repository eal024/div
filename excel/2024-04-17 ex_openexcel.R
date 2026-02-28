# Packages
library(openxlsx)
library(tidyverse)

# Create workbook and sheet
wb <- createWorkbook()
addWorksheet( wb, "statistikk")
addWorksheet( wb, "post70")

df <- vroom::vroom("data/2023-09-19 eks_mottakere.csv" ) |>
    mutate( periode = seq.Date( from = ymd("2016-01-01"), length.out = n(), by = "month" ),
            mottakere = str_remove(mottakere, " " ) |> as.numeric()
    )
    
# 
openxlsx::writeData(wb = wb, x = df, sheet = "statistikk", startCol = 1, startRow = 1)

# tabell 1
start <- 2018
slutt <- 2022

tabell_ar <- c(start:slutt)
openxlsx::writeData(wb, sheet = "post70", startCol = 1, startRow = 1, x = c("ar")  )
openxlsx::writeData(wb, sheet = "post70", startCol = 1, startRow = 2, x = tabell_ar )

v <- c("=(statistikk!B:B;post70!A2;statistikk!C:C)")

writeFormula(wb, sheet = "post70", x = v, startCol = 2, startRow = 2)

walk2( 1, v, \(i,v)  writeFormula(wb, sheet = 2, x = v, startCol = 2, startRow = 5))

#writeFormula(wb, sheet = 2, x = v, startCol = 10, startRow = 2)


saveWorkbook(wb, file = "data_export/2023-09-13 excel_example.xlsx", overwrite = T)


