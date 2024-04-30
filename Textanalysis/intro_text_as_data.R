

library(tidyverse)

# data--------------------------------------
review_data <- vroom::vroom("data/Roomba Reviews.csv") |> janitor::clean_names()

# Text as data
review_data |> 
    # Product summerise
    filter(  str_detect(Product, "iRobot")) |> 
    summarise(
        mean = mean(Stars)
    )


# Tokenizing and cleaning-------------------

# Impose structre to the data

# packages
library(tidytext)

# Each rev. to a 
# Bag of words: words in a document that are independent
# Separata body of text is a docuemnt
# word = term
# occurrence of a term = token

review_data |> unnest_tokens(word, review)
