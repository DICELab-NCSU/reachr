#' Read files produced by Emlid software as simple features
#'
#' @param file string. Path to file containing spatial data.
#' @param format string. The file format of the data. Defaults to guessing based on the file
#' extension.
#' @param crs string. The coordinate reference system for the spatial data, supplied as an
#' EPSG code, WKT, or proj4string.
#'
#' @return object of class sf
#' @importFrom utils read.csv
#' @export

read_emlid <- function(file, format = c("guess", "shp", "csv", "csv_penzd", "dxf", "pos"),
                       crs = NULL) {
  format <- match.arg(format)
  if(format %in% c("csv_penzd")) stop("This file format is not yet supported.")
  if(format == "guess") {
    format <- stringr::str_extract(file, pattern = "\\.([A-z]+$)", group = TRUE)
  }
  rawdat <- switch (format,
                    "csv" = read.csv(file),
                    "shp" = sf::st_read(file),
                    "dxf" = sf::st_read(file, query = 'select *, OGR_STYLE from entities',
                                        as_tibble = FALSE, stringsAsFactors = TRUE),
                    "pos" = read_emlid_pos(file)
  )
  if(format == "csv") {

  }
  if(!is.null(crs) & is.null(sf::st_crs(rawdat))) {

  }
}
