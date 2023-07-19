#' Check if sf geometry is suitable for importing into Emlid Flow
#'
#' @param x An sf object.
#'
#' @return logical. TRUE indicates that current geometry type is compatible for import.
#' @details
#' Emlid Flow currently supports only (multi)point geometries.
#'
#' @seealso [as_ef_geom()]
#' @export

check_ef_geom <- function(x) {
  all(sf::st_geometry_type(x) %in% c("POINT", "MULTIPOINT"))
}
