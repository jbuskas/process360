# process360
A prototype R Shiny application that provides multiple views of the forest based on a single 360 equirectangular image.

## Structure
The `main` branch contains the version of the application where the user uploads the 360 image to be transformed. The function then uses FFmpeg to generate a stereographic hemispherical photo of the canopy, and four photos each of the forest floor and understory. The function `equirectangular_to_hemi_ffmpeg` is directly taken from FMSMicroClimMods and generates a hemispherical photo of the canopy from a given equirectangular 360 photos. The `get_forest_floor` and `get_understory` functions generate four photos of the forest floor and understory.

The `database_version` branch is an alternative approach which uses a SQLite database of pre-generated images to display. The function database_setup.R can be modified to change the images stored in the database.

The `www` folder contains a set of test images and results. When testing the application, store images in this folder - this is the folder which Shiny checks.

## How to Run
From the R console, use the following commands:

```
library(shiny)
runApp()
```
The application will then open in a new window of RStudio.
