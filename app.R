library(shiny)
library(dplyr)
library(bslib)
library(magick)
library(RSQLite)

# source("equirectangular_to_hemi_ffmpeg.R")
# source("get_forest_floor.R")
# source("get_understory.R")

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
        list("Site1" = "Site1", "choice Site2" = "Site2")
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

  observe({
    sites <- dbGetQuery(con, "SELECT DISTINCT site FROM images")
    updateSelectInput(session, "select", choices = sites$site)
  })

  image_data <- reactiveVal(NULL)
  hemi_data <- reactiveVal(NULL)
  floor_data <- reactiveVal(NULL)
  understory_data <- reactiveVal(NULL)

  observeEvent(input$select, {
    req(input$select)

    # Query the database for the selected site
    query <- dbGetQuery(con, sprintf("SELECT * FROM images WHERE site = '%s'", input$select))

    # Extract image paths
    image_data(query$original_image[1])
    hemi_data(query$hemi_image[1])
    floor_data(strsplit(query$forest_floor_images[1], ",")[[1]])
    understory_data(strsplit(query$understory_images[1], ",")[[1]])

    # Render UI outputs
    output$originalImage <- renderUI({
      req(image_data())
      print(paste("Original image path:", image_data()))
      tags$img(src = image_data(), style = "max-width: 100%; height: auto;")
    })

    output$hemiImage <- renderUI({
      req(hemi_data())
      print(paste("hemi_data path:", hemi_data()))
      tags$img(src = hemi_data(), style = "max-width: 100%; height: auto;")
    })

    output$forestFloorImage <- renderUI({
      req(floor_data())
      print(paste("floor_data path:", floor_data()))
      tagList(
        lapply(floor_data(), function(img) {
          tags$img(src = img, style = "max-width: 48%; margin: 1%; height: auto;")
        })
      )
    })

    output$understoryImage <- renderUI({
      req(understory_data())
      print(paste("understory_data path:", understory_data()))
      tagList(
        lapply(understory_data(), function(img) {
          tags$img(src = img, style = "max-width: 48%; margin: 1%; height: auto;")
        })
      )
    })
  })

  onStop(function() {
    dbDisconnect(con)
  })
}

shinyApp(ui, server)
