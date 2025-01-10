

library(fs)

# Create a test-folder for the example
if( dir_exists("fs-example") ){
    TRUE
    }else{
        dir_create("fs-example")
    }


# example-files
files <- c("RAW_DATA.csv", "clean_data.R", "1-analysis.R", "REPORT.qmd")

file_create("fs_example", files)

# Look at the folder
dir_tree("fs_example")

# Changing names/cleaning the folder
old <- dir_ls("fs-example")

new <- old |> 
    str_to_lower() |> 
    str_replace_all(" ", "-") |> 
    str_replace_all("_", "-")

file_create( "fs-example", new)

file_move( old, new)
dir("fs-example")

## Organizing the files in subfolders
subdir <- c("R", "data", "reports")

dir_create("fs-example", subdir)

fs::dir_tree("fs-example")

r_files <- dir_ls("fs-example", glob = "*.r|.R")
r_data <- dir_ls("fs-example", glob = "*.csv")
report <- dir_ls("fs-example", glob = "*.qmd")

file_move( r_files, "fs-example/R")
file_move( r_data, "fs-example/data")
file_move( report, "fs-example/reports")

fs::dir_tree("fs-example")

# Creating a function for organize the files:
organize_files <- function(folder) {
  subdirs <- c("R", "data", "reports")

  dir_create(folder, subdirs)

  r_files <- dir_ls(folder, glob = "*.r|*.R")
  data_files <- dir_ls(folder, glob = "*.csv|*.xlsx")
  reports <- dir_ls(folder, glob = "*.qmd|*.pdf")

  file_move(r_files, path(str_glue("{folder}/R")))
  file_move(data_files, path(str_glue("{folder}/data")))
  file_move(reports, path(str_glue("{folder}/reports")))
}

# Run the function
# organize_files("fs-example")


