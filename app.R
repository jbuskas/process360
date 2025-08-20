library(shiny)
library(dplyr)
library(bslib)
library(magick)

source("equirectangular_to_hemi_ffmpeg.R")
source("get_forest_floor.R")

# increase maximum image upload size to allow for larger image input
options(shiny.maxRequestSize = 100*1024^2)

ui <- fluidPage(
  titlePanel("Image Upload and Transformation"),

  sidebarLayout(
    sidebarPanel(
      fileInput("image", "Choose an Image File",
                accept = c('image/png', 'image/jpeg'))),

    mainPanel(
      h4("Original Image"),
      uiOutput("originalImage"),
      h4("Stereographic Hemispherical Image"),
      uiOutput("hemiImage"),
      h4("Forest Floor"),
      uiOutput("forestFloorImage")
    )
  )
)

server <- function(input, output, session) {
  image_data <- reactiveVal(NULL)
  hemi_data <- reactiveVal(NULL)
  floor_data <- reactiveVal(NULL)

  observeEvent(input$image, {
    req(input$image)


    test_file <- file.path(tempdir(), "write_test.txt")

    # Try writing a file
    tryCatch({
      writeLines("Write test successful!", test_file)
      message("✅ Write access confirmed: ", test_file)
    }, error = function(e) {
      message("❌ Write access denied: ", e$message)
    })

  #   infile <- input$image$datapath
  #   print(infile)
  #   working_path <- file.path("www", input$image$name)
  #   file.copy(infile, working_path, overwrite = TRUE)
  #   equirectangular_to_hemi_ffmpeg(filename = working_path)
  #   get_forest_floor(filename = working_path)
  #
  #   image_data(input$image$name)
  #   hemi_data(paste0(tools::file_path_sans_ext(input$image$name), "_hemi.jpg"))
  #   floor_data(paste0(tools::file_path_sans_ext(input$image$name), "_floor.jpg"))
  #
  #   output$originalImage <- renderUI({
  #     req(image_data())
  #     tags$img(src = image_data(), style = "max-width: 100%; height: auto;")
  #   })
  #
  #   output$hemiImage <- renderUI({
  #     req(hemi_data())
  #     tags$img(src = hemi_data(), style = "max-width: 100%; height: auto;")
  #   })
  #
  #   output$forestFloorImage <- renderUI({
  #     req(floor_data())
  #     tags$img(src = floor_data(), style = "max-width: 100%; height: auto;")
  #   })
  #
  })

}

shinyApp(ui, server)
