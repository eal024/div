# Packages
library(openxlsx)
library(tidyverse)

# Create workbook and sheet
wb <- createWorkbook()
addWorksheet( wb, "Sheet 1")
addWorksheet( wb, "Sheet 2")


# 
openxlsx::writeData(wb, sheet = "Sheet 1", startCol = 1, startRow = 1, x = head(iris) )


# Anslag
v <- c("SUM('Sheet 1'!A:A)", "AVERAGE('Sheet 1'!A:A)")

walk2( 1:2, v, \(i,v)  writeFormula(wb, sheet = 2, x = v, startCol = i, startRow = 5))
#writeFormula(wb, sheet = 2, x = v, startCol = 10, startRow = 2)


saveWorkbook(wb, file = "data_export/2023-09-13 excel_example.xlsx", overwrite = T)


