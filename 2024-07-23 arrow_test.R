
# Intro to the arrow packages and apache
# From the the blog: https://blog.djnavarro.net/posts/2021-11-19_starting-apache-arrow-in-r/

# packages
library(arrow)
library(dplyr)
library(ggplot2)

# Example data
diamonds

diamonds |> 
    filter( cut == "Premium") |> 
    count()


# Convert to arrow:
diamonds2 <- arrow_table(diamonds)

# Compare the size
lobstr::obj_sizes(diamonds) # The size before adjusting.
lobstr::obj_sizes(diamonds2) # The size before adjusting.
as.numeric(object.size(diamonds)/object.size(diamonds2)) # The comparable size diff

# Using dplyr with arrow-------------------------------------
diamonds2 |> 
    filter( cut == "Premium") |> 
    count(clarity)   |> 
    collect()
    
df <- tibble( date = seq.Date( from = as.Date("2000-01-01"), by = "month", length.out = 2000))

# Read csv to arrow-----------------------------------------
arrow_csv <- read_delim_arrow("data/ung_ufor.csv", as_data_frame = FALSE,   delim = "\t")

# Data prepering of arrow data
arrow_csv1 <- arrow_csv |>
    mutate( 
        periode = lubridate::ym(periode),
        ar = year(periode)
        )  |> 
    collect()


## Re writing the data 
# dir.create("data/ung_ufor")
arrow_csv1 |> 
    group_by( ar ) |> 
    write_dataset(path = "data/ung_ufor", format = "parquet")

fs::dir_ls("data/ung_ufor")
fs::dir_tree("data/ung_ufor")

# Open the dataset again
ppath <- "data/ung_ufor"

ung_ufor_parac <- open_dataset(ppath)
glimpse(ung_ufor_parac)

# query from the data--------------------------------------

query <- ung_ufor_parac |> 
    filter( ar == 2022)  |> 
    mutate( ar2 = ar*10) |> 
    summarise( 
        total_tilgang = sum(tilgang),
        antall_snitt_beholdning = mean(antall)
    )


# Time
query |> collect() |> system.time()

# 
ung_ufor_parac 












