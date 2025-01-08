
#
library(tinyplot)

# The basisc plot
tinyplot( data = iris, Sepal.Length ~ Petal.Length| Species)

# Alternative for saving taping.
plt( data = iris, Sepal.Length ~ Petal.Length| Species)


# 
plt(
    data = iris,
    Sepal.Length ~ Petal.Length| Species,
    palette = "dark",
    pch = 16,
    grid = T,
    frame = F
    )



# Histogram
plt(
    data = iris,
    ~ Petal.Length| Species,
    type = "density",
    fill = "by",
    palette = "dark",
    pch = 16,
    grid = T,
    frame = F,
    main = "The main text title"
)

# Faciting
plt(
    data = iris,
    Sepal.Length ~ Petal.Length| Species,
    facet = ~Species,
    facet.args =  list(bg = "gray90"),
    palette = "dark",
    pch = 16,
    grid = T,
    frame = F
)

