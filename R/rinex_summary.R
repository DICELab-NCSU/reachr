#' Summarize Rinex observation file
#'
#' @param rinex Path to Rinex observation file (.YYo where YY are the last two digits of the observation year).
#'
#' @returns A list containing the Rinex version, number of satellites in used from each constellation, and the observation start/end times.
#' @export
#'
#' @examples
#'\dontrun{
#' rinex_summary(rinex = "path/to/file.25o")
#'}
rinex_summary <- function(rinex) {
  lines <- readLines(rinex, n = 100, warn = FALSE)

  system_codes <- c("G", "R", "E", "S", "C", "J", "I")
  system_names <- c(
    G = "GPS",
    R = "GLONASS",
    E = "Galileo",
    S = "SBAS",
    C = "BeiDou",
    J = "QZSS",
    I = "NavIC"
  )

  # Parse Rinex version number
  vers <- as.numeric(regmatches(lines[1], regexpr("[0-9].[0-9]+", lines[1])))

  # Satellite counts from SYS / # / OBS TYPES lines
  obs_type_lines <- grep("SYS / # / OBS TYPES", lines, value = TRUE)

  # Extract system letter and number of satellites
  sat_counts <- stats::setNames(rep(0L, length(system_codes)), system_codes)
  for (ln in obs_type_lines) {
    sys <- substr(ln, 1, 1)
    # the number of satellites is in cols 6-6? No — RINEX format: cols 6-6? Actually 2-6? We'll match with regex
    num <- as.integer(trimws(substr(ln, 6, 7)))
    if (!is.na(num) && sys %in% system_codes) {
      sat_counts[sys] <- num
    }
  }

  sat_df <- data.frame(
    name   = system_names[system_codes],
    count  = as.integer(sat_counts),
    stringsAsFactors = FALSE
  )

  # Time range
  time_first <- if (any(grepl("TIME OF FIRST OBS", lines))) {
    parse_rinex_time(lines[grep("TIME OF FIRST OBS", lines)])
  } else NA

  time_last <- if (any(grepl("TIME OF LAST OBS", lines))) {
    parse_rinex_time(lines[grep("TIME OF LAST OBS", lines)])
  } else NA

  # Return result
  list(
    rinex_version = vers,
    satellites = sat_df,
    time_start = time_first,
    time_end = time_last
  )
}

#' @noRd
parse_rinex_time <- function(line) {
  vals <- as.integer(scan(text = line, what = character(), quiet = TRUE)[1:6])
  if (length(vals) >= 6) {
    as.POSIXct(sprintf("%04d-%02d-%02d %02d:%02d:%06.3f",
                       vals[1], vals[2], vals[3],
                       vals[4], vals[5], vals[6]),
               tz = "UTC")
  } else {
    NA
  }
}
