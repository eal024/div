
# solving a programming case with ellmer
library(ellmer)
here::here("appendix.R") # promts

chat <- chat_openai(
  model = "gpt-4o-mini",
  system_prompt = "
  You are an expert R programmer who prefers tidyverse.
  Just give me the code. I don't want any explanation or sample data.

  Follow this coding style guide:
  * Spread long function calls across multiple lines.
  * Where needed, always indent function calls with two spaces.
  * Only name arguments that are less commonly used.
  * Always use double quotes for strings.
  * Use the base pipe, `|>`, not the magrittr pipe `%>%`.
  * Do not add ```r ```. But start each line with #
  ",
)


chat$chat(
    "I have a dataset, with one row for each person. The variable bidrag gives a sum for each month. How can I calcuate the rowsum for each individ, summing only variables with the name `bidrag_`")


chat$chat( "In the data frame df5, the order of the variable is dp_1, dp_5, dp_4, dp_3, dp_2. How can I order them from _1 to _5?" )

chat$chat( "do you have a general way to order them, not by spesifying the numer _1, _2?" )
