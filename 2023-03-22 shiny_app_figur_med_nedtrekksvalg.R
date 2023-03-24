

library(shiny)
library(highcharter)

# Data
Sys.setlocale("LC_CTYPE")
data <- read.csv("data/figurdata 4.1.csv") |> unique()

# Navngi valg i app
omrade <- setNames(unique(data$omrade), unique(data$omrade) ) #
versjon <- setNames( c("Hovedalternativet","Lav nasjonal vekst", "Høy nasjonal vekst" ), c("Hovedalternativet","Lav nasjonal vekst", "Høy nasjonal vekst" ) )

#
ui <- fluidPage(
    titlePanel("Figur med nedtrekksvalg"),
    sidebarLayout(
        sidebarPanel(
            selectInput('omrade', 'Geografi', names(omrade) )
        ),
        mainPanel(
            highchartOutput("plot")
        )
    )
)

server <- function(input, output) {
    
    dataset <- reactive({
        subset_data <- data[data$omrade == input$omrade, ]
        subset_data <- na.omit(subset_data)
        subset_data
    })  
    output$plot <- renderHighchart({
        
        highchart() |>
            hc_add_series( data = dataset(),
                           type = "line",
                           hcaes(y = value, x = ar, group = factor(versjon) )
            ) %>%
            hc_xAxis(title = list(text = "")) %>%
            hc_yAxis(title = list(text = "Befolkningsantall")) |> 
            hc_plotOptions( series = list( marker = list(enabled = F) )
            )
        
    })  
    
}

shinyApp(ui = ui, server = server)
