


test <- c("åse", "ærver", "øse")


chartr( "æøå", "aoa", test)


norwegian_to_ascii <- function(str_vec){

    str_vec <- iconv(str_vec, from = "", to = "UTF-8", sub = "")
    chartr( "æøå", "aoa", tolower(str_vec) )

}


norwegian_to_ascii( test)
