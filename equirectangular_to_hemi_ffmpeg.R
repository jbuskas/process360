#' FFmpeg Hemi Photo Processing in R
#'
#' @description
#' Runs an FFMPeg command to resize and reproject Insta360 equirectangular photos to an stereographic projection hemispherical photo.
#'
#' @param filename Name of the file to be processed. In batch processing this will be the first file to be processed, and the rest of the .jpg images in the same folder will be processed as well.
#'
#' @return None - saves the processed files in the same directory specified
#' @examples
#'
#' This will process only test.jpg.
#' equirectangular_to_hemi_ffmpeg(C:/FFmpeg/bin/test.jpg)
#'
#' This will process all .jpg files in the photos folder.
#' equirectangular_to_hemi_ffmpeg(C:/photos/equi_picture.jpg, batch=TRUE)

equirectangular_to_hemi_ffmpeg <- function(filename=NULL) {
    cmd <- sprintf("ffmpeg -i %s -vf v360=e:sg:pitch=90:h_fov=190:v_fov=190:ih_fov=360:iv_fov=180,scale=1750:-1 -y %s_hemi.jpg", filename, tools::file_path_sans_ext(filename))
    system(cmd)
}
