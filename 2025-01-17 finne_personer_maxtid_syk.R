
library(tidyverse)

pp <- seq.Date( from = as.Date("2020-01-01"), length.out = 24, by = "month" )

fn_person <- function(id){
    psyk <- sample(x = 1:10,   size = 1)
    syk <- rep( "syk", times = psyk)
    ufor <- 24-psyk
    rand_ufor <- sample( x = c("ufor", "arbeid"), size = 1)
    ufor <- rep( rand_ufor, times = 24-psyk )  
    
    vec <- c(syk,ufor)
    
    per <- seq.Date( from = as.Date("2020-01-01"), length.out = 24 , by = "month" )
    tibble( periode = per, fk_person1 = id, ytelse = vec)
}

df <- map(1:10, \(x) fn_person( id = x)) |> 
    bind_rows()


syk <- df |> filter( ytelse == "syk")
ufor <- df |> filter( ytelse == "ufor")


tbl <- syk |> 
    group_by(periode) |> 
    nest() |>
    rename( syk = data) |>  
    left_join( 
        ufor |>
        group_by(periode) |>
        nest() |> 
        rename( ufor = data),
        join_by(periode)
        ) |> 
        ungroup()

p_t <- 1:10
p_t_1 <- 2:10

p_t[p_t %in% p_t_1]

# Skal finne personer som mottar sykepenger mnd t, ikke t+1, men istedet går til ufore
tbl |>
    mutate(
        # Personer som mottar syk
        fk_t_1 = map(syk, \(df) df$fk_person1) |> lag(), # t-1 : sist periode
        fk_t   = map(syk, \(df) df$fk_person1),          # t   : denne perioden
        avg_syk = map2(fk_t_1, fk_t, \(t_1, t) t_1[ ! t_1 %in% t])
    )  |> 
    # Tilgang uføretrygd: finner vi de igjen i ufore-registret?
    slice(2:10) |> 
    mutate(
        tilgang_ufor = map2(avg_syk, ufor, \(x, df){
            if( )


        } df |> filter( x %in% fk_person1) )
    )


a <- tibble( fk_person1 = vector())



tbl$ufor[[2]] |> 
    filter( a$fk_person1  %in% fk_person1)
