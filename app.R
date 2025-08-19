library(shiny)
library(dplyr)
library(bslib)
library(magick)

source("equirectangular_to_hemi_ffmpeg.R")

# increase maximum image upload size to allow for larger image input
options(shiny.maxRequestSize = 100*1024^2)

ui <- fluidPage(
  titlePanel("Image Upload and Transformation"),

  sidebarLayout(
    sidebarPanel(
      fileInput("image", "Choose an Image File",
                accept = c('image/png', 'image/jpeg')),
      actionButton("process", "Transform Image")
    ),

    mainPanel(
      h4("Original Image"),
      uiOutput("originalImage"),
      h4("Transformed Image"),
      uiOutput("transformedImage")
    )
  )
)

server <- function(input, output, session) {
  image_data <- reactiveVal(NULL)
  transformed_data <- reactiveVal(NULL)

  observeEvent(input$image, {
    req(input$image)
    infile <- input$image$datapath
    print(infile)
    working_path <- file.path("www", input$image$name)
    file.copy(infile, working_path, overwrite = TRUE)
    equirectangular_to_hemi_ffmpeg(filename = working_path)

    image_data(input$image$name)
    transformed_data(paste0(tools::file_path_sans_ext(input$image$name), "_hemi.jpg"))

    output$originalImage <- renderUI({
      req(image_data())
      tags$img(src = image_data(), style = "max-width: 100%; height: auto;")
    })

    output$transformedImage <- renderUI({
      req(transformed_data())
      tags$img(src = transformed_data(), style = "max-width: 100%; height: auto;")
    })

  })

}

shinyApp(ui, server)
