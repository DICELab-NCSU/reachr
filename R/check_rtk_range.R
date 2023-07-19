#' Check that points or area of interest are within range of proposed RTK base.
#'
#' @import sf
#' @import units
#' @import ggplot2
#'
#' @param rover sf object. Point(s) or polygon(s) containing the area of interest where the rover will be used.
#' @param base sf object. A point containing the proposed coordinates of the RTK base.
#' @param local_crs String. A projected coordinate reference system, either an EPSG code, WKT, or proj4string.
#' @param range Numeric. The nominal range of the LoRa signal in meters, defaults to 8000 m (=8 km).
#' @param plot Logical. Whether or not
#'
#' @returns Logical, also a message reporting the result and (optionally) a ggplot.
#' @export

check_rtk_range <- function(rover, base, local_crs = getOption("local_crs"),
                            range = getOption("lora_range", 8000), plot = TRUE) {
  if(sf::st_is_longlat(local_crs)) stop("local_crs must be projected!")
  if(!identical(sf::st_crs(rover), sf::st_crs(base)) & plot) stop("rover and base must be in the same crs when plot = TRUE")
  local_crs <- sf::st_crs(local_crs)
  lunits <- as.numeric(units::set_units(sf::st_crs(local_crs)$ud_unit, "m"))  # convert linear units of projection system to m
  # re-project coordinates into local_crs
  lrover <- sf::st_transform(rover, crs = local_crs)
  lbase <- sf::st_transform(base, crs = local_crs)
  lbuffer <- sf::st_buffer(lbase, range / lunits, nQuadSegs = 100)
  out <- all(sf::st_contains(lbuffer, lrover, sparse = FALSE))
  message("All rover geometries are covered by the base?: ", out)
  if(plot) {
    buffer <- sf::st_transform(lbuffer, crs = sf::st_crs(rover))
    ggplot2::ggplot()+
      ggplot2::geom_sf(data = buffer, ggplot2::aes(color = "Base"), fill = "transparent")+
      ggplot2::geom_sf(data = base, ggplot2::aes(color = "Base"))+
      ggplot2::geom_sf(data = rover, ggplot2::aes(color = "Rover"))+
      ggplot2::scale_color_manual("GNSS unit", values = c("cornflowerblue", "red"))
  }
  return(out)
}
