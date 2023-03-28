library(shiny)
library(highcharter)

ui <- fluidPage(
    titlePanel("Highcharter Plot in Shiny App"),
    sidebarLayout(
        sidebarPanel(
            numericInput("num", "Enter a number:", value = 100)
        ),
        mainPanel(
            highchartOutput("plot")
        )
    )
)

server <- function(input, output) {
    output$plot <- renderHighchart({
        data <- rnorm(input$num)
        highchart() %>% 
            hc_chart(type = "column") %>% 
            hc_add_series(data) %>% 
            hc_xAxis(title = list(text = "Value")) %>% 
            hc_yAxis(title = list(text = "Frequency"))
    })
}

shinyApp(ui = ui, server = server)