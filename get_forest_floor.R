#' Forest Floor Image Creator
#'
#' @description
#' Runs an FFMPeg command to resize and reproject Insta360 equirectangular photos to an stereographic projection
#' hemispherical photo of the forest floor.
#'
#' @param filename Name of the file to be processed.
#'
#' @return None - saves the processed files in the same directory as filename
#' @examples
#'
#' This will process only test.jpg.
#' get_forest_floor(C:/FFmpeg/bin/test.jpg)

get_forest_floor <- function(filename=NULL) {
  # Zooms to the center of the image by the level specified
  zoom_level <- 4
  zoomed_width <- 1750 / zoom_level
  zoomed_height <- 1750 / zoom_level
  # Calculate the center x and y coordinates of each quadrant - zoompan's x and y coordinates specify the top left corner of the image
  centers <- list(
    top_left = c(600, 600),
    top_right = c(1150, 600),
    bottom_left = c(600, 1150),
    bottom_right = c(1150, 1150)
  )

  # Generate zoomed images for each quadrant
  for (quad in names(centers)) {
    center_x <- centers[[quad]][1]
    center_y <- centers[[quad]][2]

    x <- center_x - zoomed_width / 2
    y <- center_y - zoomed_height / 2

    zoom_cmd <- sprintf(
      "ffmpeg -i %s -vf v360=e:sg:pitch=-90,scale=1750:-1,zoompan=z=%s:x=%s:y=%s:s=750x750:d=1 -y %s_%s_zoomed.jpg",
      filename, zoom_level, x, y, tools::file_path_sans_ext(filename), quad
    )
    system(zoom_cmd)
  }
}
