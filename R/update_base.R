#' Update coordinates to use a new base position
#'
#' @param points path to a file produced using the Emlid Flow csv export tool
#' @param newbase path to a file containing the updated base coordinates
#' @param base_row (optional) row containing the updated base coordinates if newbase contains
#' multiple points
#' @param destfile (optional) path to write a csv file containing corrected points
#'
#' @return a tibble following the formatting conventions of Emlid Flow csv export
#' @export
#'

update_base <- function(points, newbase, base_row = NULL,
                        destfile = NULL){
  if(is.character(points)) suppressMessages(points <- utils::read.csv(points))
  if(is.character(newbase)) suppressMessages(newbase <- read_emlid(newbase))
  if(is.null(base_row) & nrow(newbase) > 1L) stop("Must specify which row of 'newbase' contains the base position")
  if(is.null(base_row)) base_row <- 1L
  newbase <- newbase[base_row, ]
  offsetN <- newbase$latitude_dd - points$`Base latitude`
  offsetE <- newbase$longitude_dd - points$`Base longitude`
  offsetU <- newbase$ellipsoidal_height_m - points$`Ellipsoidal height`
  out <- points
  out$Longitude <- out$Longitude + offsetE
  out$Latitude <- out$Latitude + offsetN
  out$`Ellipsoidal height` <- out$`Ellipsoidal height` + offsetU
  out$`Base longitude` <- newbase$longitude_dd
  out$`Base latitude` <- newbase$latitude_dd
  out$`Base ellipsoidal height` <- newbase$ellipsoidal_height_m
  if(!is.null(destfile)) utils::write.csv(out, file = destfile, na = "")
  return(out)
}