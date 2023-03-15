

# Sp??rreunders??kelse samfunns??konomnene

library(tidyverse)

df <- readxl::read_excel("data/Medlemsunders??kelse Samfunns??konomene i NAV(1-25).xlsx") |> 
    janitor::clean_names()

Sys.setlocale("LC_CTYPE")
df1 <- df |> 
    select( nav = hvor_jobber_du_i_nav, 
            fornoyd = hvor_fornoyd_er_du_med_hjelpen_du_har_fatt_av_de_tillitsvalgte
            ) |> 
    mutate( fornoyd =     factor(fornoyd, levels = c("Misforn??yd",
                                                    "Ikke relevant",
                                                    "Vet ikke",
                                                    "Hverken eller",
                                                    "Forn??yd",
                                                    "Veldig forn??yd"
                                                    )),
            nav = factor(nav)
            )

# Graf
df2 <- df1 |> 
    summarise( antall = n(), .by = c(fornoyd,nav)
               ) |>
    mutate( andel = antall/sum(antall), .by = nav) |> 
    complete(fornoyd,nav , fill = list(antall = 0, andel = 0)
             ) 

Sys.setlocale("LC_CTYPE")
df2 |>
    ggplot(aes( y = andel, x = fornoyd, fill = nav, color = nav) ) +
    geom_col( position = position_dodge2( ) 
              ) +
    theme_minimal( base_size = 14) +
    theme( legend.title = element_blank()
           ) +
    scale_y_continuous( labels = scales::percent_format( accuracy = 1) ) +
    # geom_text( data = df2 |> filter(fornoyd == "Veldig forn??yd"),
    #            aes( y = andel, x = fornoyd,label = str_c("N:",antall) ), color ="black", vjust = -0.5,hjust = 0,
    #            position = position_dodge(0.9)
    #            ) +
    labs( x = "", y = "")
