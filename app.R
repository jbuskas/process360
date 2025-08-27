library(shiny)
library(dplyr)
library(bslib)
library(magick)
library(RSQLite)

source("equirectangular_to_hemi_ffmpeg.R")
source("get_forest_floor.R")
source("get_understory.R")

# increase maximum image upload size to allow for larger image input
options(shiny.maxRequestSize = 100*1024^2)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f5f5f5;
        font-family: 'Segoe UI', sans-serif;
      }
      .title {
        color: #2c3e50;
        text-align: center;
        margin-bottom: 30px;
      }
      .panel-heading {
        font-size: 18px;
        font-weight: bold;
        color: #34495e;
        margin-top: 20px;
      }
      .image-section {
        background-color: #ffffff;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 20px;
      }
    "))
  ),

  titlePanel(div("Database of 360 Image Transformations", class = "title")),

  sidebarLayout(
    sidebarPanel(
      tags$h4("Site Selection"),
      selectInput(
        "select",
        "Select a site below:",
        list("Choice Site1" = "C:\\Users\\jbuskas\\OneDrive - NRCan RNCan\\Project\\process360\\www", "choice Site2" = "Site2")
      ),
      tags$hr(),
      tags$p("This application shows the transformation of an equirectangular 360 image into multiple views of the forest.")
    ),

    mainPanel(
      div(class = "image-section",
          div(class = "panel-heading", "Original Image"),
          uiOutput("originalImage")
      ),
      div(class = "image-section",
          div(class = "panel-heading", "Stereographic Hemispherical Image"),
          uiOutput("hemiImage")
      ),
      div(class = "image-section",
          div(class = "panel-heading", "Forest Floor"),
          uiOutput("forestFloorImage")
      ),
      div(class = "image-section",
          div(class = "panel-heading", "Understory"),
          uiOutput("understoryImage")
      )
    )
  )
)

server <- function(input, output, session) {
  con <- dbConnect(RSQLite::SQLite(), "data/image_database.sqlite")

  image_data <- reactiveVal(NULL)
  hemi_data <- reactiveVal(NULL)
  floor_data <- reactiveVal(NULL)
  understory_data <- reactiveVal(NULL)

  observe({
    sites <- dbGetQuery(con, "SELECT DISTINCT site FROM images")
    updateSelectInput(session, "select", choices = sites$site)
  })

  observeEvent(input$select, {
    req(input$select)

    infile <- input$image$datapath
    print(infile)
    working_path <- file.path("www", input$image$name)
    file.copy(infile, working_path, overwrite = TRUE)
    equirectangular_to_hemi_ffmpeg(filename = working_path)
    get_forest_floor(filename = working_path)
    get_understory(filename = working_path)

    image_data(input$image$name)
    hemi_data(paste0(tools::file_path_sans_ext(input$image$name), "_hemi.jpg"))

    # Store all 4 quadrant image paths
    quadrants <- c("top_left", "top_right", "bottom_left", "bottom_right")
    zoomed_images <- paste0(tools::file_path_sans_ext(input$image$name), "_", quadrants, "_zoomed.jpg")
    floor_data(zoomed_images)

    # Get understory image paths
    directions <- c("east", "north", "south", "west")
    understory_images <- paste0(tools::file_path_sans_ext(input$image$name), "_", directions, "_understory.jpg")
    understory_data(understory_images)

    output$originalImage <- renderUI({
      req(image_data())
      tags$img(src = image_data(), style = "max-width: 100%; height: auto;")
    })

    output$hemiImage <- renderUI({
      req(hemi_data())
      tags$img(src = hemi_data(), style = "max-width: 100%; height: auto;")
    })


    output$forestFloorImage <- renderUI({
      req(floor_data())
      tagList(
        lapply(floor_data(), function(img) {
          tags$img(src = img, style = "max-width: 48%; margin: 1%; height: auto;")
        }))})

    output$understoryImage <- renderUI({
      req(understory_data())
      tagList(
        lapply(understory_data(), function(img) {
          tags$img(src = img, style = "max-width: 48%; margin: 1%; height: auto;")
        }))})
  })
}

shinyApp(ui, server)
