
# Packages
library(openxlsx)
library(tidyverse)


wb <- createWorkbook()
addWorksheet( wb, "Sheet 1")

v <- c("SUM('Sheet 1'!A:A)", "AVERAGE('Sheet 1'!A:A)")

writeFormula(wb, sheet = 2, x = v, startCol = 10, startRow = 2)

saveWorkbook(wb, file = "data_export/excel_wb_example.xlsx", overwrite = T)

addWorksheet( wb, "Sheet 2")
addWorksheet( wb, "Sheet 3")
writeData(wb, 1, iris)

v <- c("SUM('Sheet 1'!A:A)", "AVERAGE('Sheet 1'!A:A)")

a <- tibble( rad = 1:10) |> 
    mutate( formel = str_c("SUM('Sheet 1'!A",rad,":A20",")")
            )


writeFormula(wb, sheet = 2, x = v, startCol = 10, startRow = 2)
writeFormula(wb, 2, x = "A2 + B2", startCol = 10, startRow = 10)

walk2( a$formel, 1:length(a$formel),\(d, i)
    writeFormula(wb, sheet = 3, x = d, startCol = 4, startRow = i)
    )


saveWorkbook(wb, file = "data_export/excel_wb_example.xlsx", overwrite = T)
