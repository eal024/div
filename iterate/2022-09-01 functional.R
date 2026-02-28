


library(tidyverse)

pwalk( list(en = 1:3, to = 11:13),function(en,to){
    x <- en*to
    print(paste0("summen av ",en, " og " ,to, " er : ",x))
}  )



for(i in 1:3){
    
    print(i)
}
