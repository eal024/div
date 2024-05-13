
text1 <- "apple, orange, banana, and grape pineapple"
text2 <- "apple,orange banana -grape pineapple"

#
strsplit(text1, ", ")

# combined with regex: , and with space and/or-
strsplit(text2, "[,\\s-]+")

# Example 3, different deliming: delim with number
text3 <- "Hello123world456R789users"

strsplit(text3, "[0-9]+")


