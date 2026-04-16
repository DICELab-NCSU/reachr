#' Write simple features spatial data to an Emlid Flow-compatible CSV file
#'
#' @param x An sf object.
#' @param file string. Path to file containing spatial data.
#'
#' @returns Invisible
#' @export
#'
write_emlid_csv <- function(x, file) {
  x <- sf::st_drop_geometry(x)
  current_names <- names(x)
  canonical_names <- c("Name", "Code", "Code description", "Easting", "Northing", "Elevation",
                       "Description", "Longitude", "Latitude", "Ellipsoidal height", "Origin",
                       "Easting RMS", "Northing RMS", "Elevation RMS", "Lateral RMS",
                       "Antenna height", "Antenna height units", "Solution status",
                       "Correction type", "Averaging start", "Averaging end", "Samples",
                       "PDOP", "GDOP", "Base easting", "Base northing", "Base elevation",
                       "Base longitude", "Base latitude", "Base ellipsoidal height",
                       "Baseline", "Mount point", "CS name", "GPS Satellites",
                       "GLONASS Satellites", "Galileo Satellites", "BeiDou Satellites",
                       "QZSS Satellites", "Device type", "Device serial number")
  canonical_match <- make.names(canonical_names)
  match_idx <- match(current_names, canonical_match)
  rename_vec <- stats::setNames(
    canonical_names[match_idx[!is.na(match_idx)]],
    current_names[!is.na(match_idx)]
  )
  current_names[current_names %in% names(rename_vec)] <- rename_vec[current_names[current_names %in% names(rename_vec)]]
  names(x) <- current_names
  missing_cols <- setdiff(canonical_names, current_names)
  if (length(missing_cols) > 0) {
    for (col in missing_cols) {
      x[[col]] <- NA
    }
  }
  out <- x[, canonical_names]
  utils::write.csv(out, file, na = "")
}
