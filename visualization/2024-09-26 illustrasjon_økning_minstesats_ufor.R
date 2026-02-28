

library(tidyverse)

# data
N <- 1000

# simmulering beregningsgrunnlaget
df <- tibble( 
    fk = 1:N,
    income = rexp( n = N , rate = 0.5),
    child  = sample( size = N, x = 0:4, prob = c(0.5, 0.3, 0.1,0.05, 0.05 ), replace = T) 
              )

df1 <-  df |> 
    # Lage ny variabel
    mutate( 
        bg  = ifelse( income > 6, 6, income),
        uft_natural = income*0.66,
        uft1 = bg*0.66,
        uft2 = case_when(
            bg*0.66 < 2.48 ~ 2.48,
            T ~ bg*0.66
            )
        )

# graf
df1 |>
    ggplot(
        aes( y = uft_natural, 
             x = income
             )
    ) +
    geom_line( 
        linetype = 2
               ) +
    geom_line(
        aes( y = uft1,
             x = income
        ),
        linetype = 3
    ) +
    geom_line(
        aes( y = uft2,
             x = income
        ),
        size =1
        #size = .8,
#        alpha = 0.8
    ) +
    theme_light( base_size = 15) +
    labs( y = "Uf??retrygd", x = "Inntekt") +
    scale_x_continuous( limits = c(0,7), breaks = seq(from = 2, to = 3, by = 0.2), labels = function(x) paste0( format(x,  0), " G") ) +
    scale_y_continuous( limits = c(0,7), breaks = seq(from = 2, to = 3, by = 0.2),, labels = function(x) paste0( format(x,  0), " G") ) -> graf2








graf2 +
    scale_x_continuous( 
        limits = c(3, 4.5),
        breaks = 0:7,
        labels = function(x) paste0( format(x,  0), " G") 
                        ) +
    scale_y_continuous( 
        limits = c( 2 ,3), 
        breaks = 0:7,
        labels = function(x) paste0( format(x,  0), " G") 
        ) +
    geom_segment(aes( x = 3.02, xend = (2.48+0.049)/0.66+0.01, y = (2.48+0.049), yend = (2.48+0.049) ), 
                 linetype = "dotted",  # You can change to "dashed" if you prefer
                 color = "red",        # Optional: set the color of the line
                 size = 1.1)  





