
library(tidytext)
library(tidyverse)

review_data <- vroom::vroom("data/Roomba Reviews.csv") |> janitor::clean_names()


# Bag of words
review_data |> 
    unnest_tokens(word, review)  |> 
    count(word) 
