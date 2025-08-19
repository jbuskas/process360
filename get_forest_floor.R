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
    cmd <- sprintf("ffmpeg -i %s -vf v360=e:sg:pitch=-90:h_fov=190:v_fov=190:ih_fov=360:iv_fov=180,scale=1750:-1 -y %s_floor.jpg", filename, tools::file_path_sans_ext(filename))
    system(cmd)
}
