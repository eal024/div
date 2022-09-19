
# 
library(tidyverse)
Sys.setlocale("LC_CTYPE")

# help:
?"'"

# non English characters
"\u00b5"

string1 <- c("en", "to", "tre", "fire", "fem")

# Length
str_length(string1)
nchar(string1)

# Collapse a vector to string
paste0( string1, collapse = ", ")

cat(str_wrap(string = string1,width = 100,
             exdent = 1,
             indent = 1),"\n")


# Regex -------------------------------------------------------------------

x <- c("Eirik","Evensandern", "Even", "Trond.vegard","Eilif Terje", "Christoffer3Lamoy")

str_view(x, "[0-9]") # Number
str_view(x, ".i..") # Mach any character one before . and to after
str_view(x, "[0-9]") # Number
str_view(x, "\\.") #  Matching .
str_view("\\", "") #  \ is writn \\ .
str_view(x, "\\d")
str_view_all(x, "\\D") # All but digits

# Anchors
str_view(x, "^(E|T)") # Start with E or T
str_view(x, "^E.*k$") # Start with E and ends wth k
str_view(x, "^E.*e$") # Start with E and ends wth k

#Forcing start and stop
str_view(x, "^E.*n$") # Start with E and ends wth k
str_view(x, "^Even$") # Start with E and ends wth k
str_view(x, "^Even$") # Start with E and ends wth k


# 14.3.3 Character classes and alternatives -------------------------------

# . any char after newline
# \d digits, \s whitespace
# [abc] a, b or c
# [^abc] Anything exceot a, b or c
# \d maches as \\d


string1
str_view(x, "[A-Z]")
str_view(x, "^[A-Z].*n$")

# Example 
str_view(x, "[A-Z].*[.].*")
str_view(x, "[A-Z].*[ ]")

str_view(x, "^(T|C).*")


# How many times pattern matches ------------------------------------------

z <- c("en laaaang sommer er over")

str_view(z, "aa?") # ?:0 or 1, 
str_view(z, "a+")  # 1 or more
str_view(z, "sommer")  # 0 or more
str_view(z, "s[a-z]*")  # 0 or more
str_view(z, "s[a-z]+")  # 1 or more

# {}
str_view(str_split(z, " ")[[1]],"^o[a-z]{5}")
str_view(str_split(z, " ")[[1]],"^o[a-z]{3}")

# {n,} n or more, {,m} at most m, {n,m} between n and m
str_view(str_split(z, " ")[[1]],"[a-z]{3,}")

# {n}: exactly n
# {n,}: n or more
# {,m}: at most m
# {n,m}: between n and m


# Grouping and backreferences ---------------------------------------------

x <- c("hehehehe","bobo","Eirik","Evensandern", "Even", "Trond.vegard","Eilif Terje", "Christoffer3Lamoy")

# Backreferences
str_view(x, "(..)\\1", match = T)
str_view(x, "(.).\\1.\\1", match = T)
str_view(x, "(..)\1", match = T)
str_view(x, "(.)(.)\\2", match = T)



# Exercises ---------------------------------------------------------------


ex1 <- c("en", "abbab", "a1a1", "turit","a", "AaAa", "BeBe")

# 1.  
# {n}: exactly n
# {n,}: n or more
# {,m}: at most m
# {n,m}: between n and m

str_view_all(ex1, "e{0,}") #?
str_view_all(ex1, "e{1,}") #+
str_view_all(ex1, "e*") #*
str_view_all(ex1, "e{0,}") #*

# 2. 
str_view(ex1, "(.)\1\1")
str_view(ex1, "(.)(.)\\2\\1")
str_view(ex1,"(..)\1")

# 3. 
str_view(ex1, "^(.)((.*\\1$))") # starts and end with the same
str_view(ex1, "^(.)((.*\\1$)|\\1?$)") # starts and end with the same
str_view(ex1, "(..)\\1") # repeated pars of letters
str_view(ex1, "([A-Za-z][A-Za-z])\\1") # repeated pars of letters
str_view(ex1, "([A-Za-z]).*\\1.*\\1") # repeated letters three places

"(.)" # Backrefer. to any char.
"(.)\\1" # Backref to any char. start 1


# str_detect --------------------------------------------------------------

library(tidyverse)
navn <-
    c(
        "hehehehe",
        "bobo",
        "Eirik",
        "Evensandern",
        "Even",
        "Trond.vegard",
        "Eilif Terje",
        "Christoffer3Lamoy"
    )

x <- c("apple", "banana", "pear")
words <- c("bil", "bule", "sky", "sanke", "sinna", "hund", "abba")

# 4 navn som begynner p?? E
sum(str_detect(navn, "E"))

# select words thats match a pettern
words[ str_detect(words, "^b")]
words[ str_detect(words, "e$")]

# Filter
words[ grepl("^b", words)]

df <- tibble( a = 1:length(words), words = words)

df |> filter(str_detect(words, "^b"))

# Count for each words how many matches
str_count( words, "n")

# Used in df:
df |> 
    mutate( konsonant = str_count(words, "[aeiou]"))

# Examples
words[str_detect(words, "^a|$a")]# Start and ends with x
words[str_detect(words, "^[aeiou]|$[aeiou]")]# start and ends with consonant
words[str_detect(words, "^[aeiou]|$[aeiou]")]# start with vowel ends with consonant

# words with highest number of vowels
df |>
    mutate( vowels = str_count(words, "[aeiou]") ) |> 
    filter( str_count(words, "[aeiou]") == max( str_count(words, "[aeiou]") ))


# Extract matches ---------------------------------------------------------

sent <- head(stringr::sentences, 50)

# Find all sentences that contain a colour:
color <- c("blue", "orange", "red", "pink")

color_match <- paste0(color, collapse = "|")

# The sentence with color
str_subset(sent, color_match)
# Extract the color
str_extract(str_subset(sent, color_match), color_match)

# Extract all (also were there is sentence with more than 1 color)
sent_more <- sentences[str_count(sentences, color_match) > 1]
str_extract_all(sent_more, color_match)

# For returning a matrix
str_extract_all(sent_more, color_match, simplify = T)








