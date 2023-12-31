#' Read files produced by Emlid software as simple features
#'
#' @param file string. Path to file containing spatial data.
#' @param format string. The file format of the data. Defaults to guessing based on the file
#' extension.
#' @param crs string. The coordinate reference system for the spatial data, supplied as an
#' EPSG code, WKT, or proj4string.
#' @param drop_z logical, whether or not to drop the z/vertical dimension from points.
#'     Defaults to FALSE.
#' @param ... passed to function that reads in the datafile
#'
#' @return object of class sf
#' @importFrom utils read.csv
#' @export

read_emlid <- function(file,
                       format = c("guess", "shp", "csv", "csv_penzd", "dxf", "pos"),
                       crs = NULL, drop_z = FALSE, ...) {
  format <- match.arg(format)
  if(format %in% c("csv_penzd")) stop("This file format is not yet supported.")
  if(format == "guess") {
    format <- stringr::str_extract(file, pattern = "\\.([A-z]+$)", group = TRUE)
  }
  rawdat <- switch (format,
                    "csv" = read.csv(file, ...),
                    "shp" = sf::st_read(file, ...),
                    "dxf" = sf::st_read(file, query = 'select *, OGR_STYLE from entities',
                                        as_tibble = FALSE, stringsAsFactors = TRUE, ...),
                    "pos" = suppressMessages(read_emlid_pos(file, ...))
  )
  if(format == "csv") {
    coords <- sf::st_as_sfc(apply(rawdat[, c("Longitude", "Latitude",
                                             "Ellipsoidal.height")],
                        1, sf::st_point, simplify = FALSE))
    out <- sf::st_as_sf(cbind(rawdat, coords))
  } else if(format == "pos"){
    coords <- sf::st_as_sfc(apply(rawdat[, c("latitude_dd", "longitude_dd",
                                             "ellipsoidal_height_m")],
                                  1, sf::st_point, simplify = FALSE))
    out <- sf::st_as_sf(cbind(rawdat, coords))
  } else {
    out <- rawdat
  }
  if(!is.null(crs) & is.na(sf::st_crs(out))) {
    sf::st_crs(out) <- crs
  } else if(!is.null(crs) & sf::st_crs(crs) != sf::st_crs(out)){
    out <- sf::st_transform(out, crs = sf::st_crs(crs))
  }
  if(drop_z) out <- sf::st_zm(out, drop = TRUE)
  return(out)
}
