library(shiny)
library(dplyr)
library(bslib)

hemi_filename <- "https://raw.githubusercontent.com/jcheng5/simplepenguins.R/main/penguins.csv"

ui <- page_fixed(
  fileInput("file1", "Choose a File"),
  verbatimTextOutput("file1_contents")
)

server <- function(input, output) {
  output$file1_contents <- renderPrint({print(input$file1)})

}

shinyApp(ui, server)
