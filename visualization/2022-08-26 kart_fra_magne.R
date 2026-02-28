
library(tidyverse)
# library(data.table)
# library(rgdal)
# library(sp)
# library(ggplot2)
# library(raster)
# library(readxl)
# library(leaflet)
# library(plyr)
# library(maptools)
# library(sf)
# library(ggiraph)
# library(maps)
# library(tidyverse)
# library(cowplot)
# library(ggspatial)
# library(plotly)
Sys.setlocale("LC_CTYPE")


# Importer to datasett (Norge og fiktivt_enkelt??r)
Norge <- vroom::vroom("data/Norge.csv")
Fiktivt_enkelt??r <- readxl::read_excel("data/fiktivt_enkeltar.xlsx")



#merger de to datasettene etter felles "id".

map <-merge(x=Norge,y=Fiktivt_enkelt??r,by="id",all.x=TRUE)



a <- ggplot(data = map,
            aes(long, lat, group = as.factor(group) ))+
    geom_polygon(aes(fill = Mottakere ), color="black")+
    scale_fill_gradient(low="white", high="navy")+
    theme_void()+
    theme(plot.margin = unit(c(1,1,1,1), "cm"))+
    labs(title = "Ledighet",
         subtitle = "Antall personer med ytelse pr. fylke i 2011",
         caption = "Kilde: NAV")

a



