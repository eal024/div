
# Load the tidyverse package which includes dplyr, tidyr, and other useful libraries
library(tidyverse)

# Create a data frame using expand_grid to generate all combinations of fk (individuals) and years (-4 to 4)
df <- expand_grid( fk = 1:4, year = -4:4  ) |> 
    # Use mutate to add income (inc), DI, and AAP columns, each generated as random normal values
    mutate(
        inc = rnorm( n(), 2, sd = .5) |> round( digits =  2),  # Income with mean ~2 and rounding to 2 digits
        DI = rnorm( n(), 1, sd = .5) |> round( digits =  2),   # DI with mean ~1 and rounding
        AAP = rnorm( n(), 1, sd = .5) |> round( digits =  2)   # AAP with mean ~1 and rounding
    )

# Convert the data frame from long format to wide format
df |> 
    pivot_wider(
        names_from = year,               # Use the 'year' column to create new columns
        values_from = c(inc, DI, AAP),   # Spread the 'inc', 'DI', and 'AAP' values across years
        names_glue = "{.value}_year{year}"  # Customize column names, e.g., inc_year-4, DI_year-3
    )