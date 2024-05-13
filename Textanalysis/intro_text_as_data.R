

library(tidyverse)

# data--------------------------------------
    mtcars[ carb %in% c(1,2), let(mpg_extra = mpg + 100),][ sort(mpg)]
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
