

# 
library(tidyverse)
library(plotly)


# data 
data <-  as_tibble(mtcars)

# Simple graph
graph <-  data |>  ggplot( aes( y = mpg, x = drat ))  +
    geom_point(aes( color = factor(cyl))) + 
    theme( legend.position = "top",
           panel.background = element_rect( colour = "white",
                                            fill = "black"
                                            )
           ) 

graph

# Plotly
plotly::ggplotly(graph)  |> 
    layout(legend = list(
        orientation = "h")
        )
