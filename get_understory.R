#' Understory Image Generator
#'
#' @description
#' Runs an FFMPeg command to resize and reproject an Insta360 equirectangular photo to capture a perspective photo of the understory.
#'
#' @param filename Name of the file to be processed.
#'
#' @return None - saves the processed files in the same directory as filename
#' @examples
#'
#' get_understory(C:/FFmpeg/bin/test.jpg)

get_understory <- function(filename=NULL) {
  # Get the different perspectives
  directions <- list(
    north = 0,
    east = -90,
    south = 180,
    west = 90
  )

  # Generate zoomed images for each quadrant
  for (dir in names(directions)) {
    yaw <- directions[[dir]]
    output_file <- sprintf("%s_%s_understory.jpg", tools::file_path_sans_ext(filename), dir)
    conversion <- sprintf("ffmpeg -i %s -vf v360=e:sg:yaw=%s:h_fov=190:v_fov=190:ih_fov=360:iv_fov=180,scale=1750:-1 -y %s", filename, yaw, output_file)
    system(conversion)
  }
}
