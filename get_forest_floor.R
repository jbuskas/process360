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
   # Converts the image to a 1750x1750 orthographic image
   conversion <- sprintf("ffmpeg -i %s -vf v360=e:sg:pitch=-90:h_fov=190:v_fov=190:ih_fov=360:iv_fov=180,scale=1750:-1 -y %s_floor.jpg", filename, tools::file_path_sans_ext(filename))
   system(conversion)
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
       "ffmpeg -i %s_floor.jpg -vf zoompan=z=%s:x=%s:y=%s:s=750x750:d=1 -y %s_%s_zoomed.jpg",
       tools::file_path_sans_ext(filename), zoom_level, x, y, tools::file_path_sans_ext(filename), quad
     )
     system(zoom_cmd)
   }
}
