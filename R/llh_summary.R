#' Summarize LLH log file to aid download of CORS/VRS corrections
#'
#' @param llh File path to .LLH log file
#' @param rnd Number of minutes to round to on both ends of the logging duration (see Details)
#' @param ... Additional arguments passed to utils::read.table()
#'
#' @details
#' The 'rnd' argument helps pad the logging interval to ensure that the VRS data include
#' the entire logging duration. A value of 0 will not pad either the start or end times,
#' resulting in an exact start time and duration of the LLH log. Positive values will
#' ceiling round the start time and floor round the stop time to the number of minutes
#' specified by the user. For example, an interval of 10:28:53-13:56:23 will round as
#' follows:
#' rnd = 0: 10:28:53-13:56:23, a duration of 03:28:30
#' rnd = 1: 10:28:00-13:57:00, a duration of 03:29:00
#' rnd = 15: 10:15:00-14:00:00, a duration of 04:15:00
#' For additional information on rounding behaviors, see ?lubridate::round_date.
#'
#' @return A list containing the average logged position and position statistics.
#' @export
#'
#' @examples
#'\dontrun{
#' llh_summary(llh = "path/to/file.llh")
#'}
#'
llh_summary <- function(llh, rnd = 0, ...) {
  # read in log file
  rawdat <- read_llh(llh, ...)
  # make output
  out <- list()
  # average lat/lon/elevation
  out$position <- colMeans(rawdat[, 3:5])
  # get duration
  start <- lubridate::ymd_hms(paste(utils::head(rawdat, 1)[, 1:2], collapse = " "))
  end <- lubridate::ymd_hms(paste(utils::tail(rawdat, 1)[, 1:2], collapse = " "))
  if(rnd > 0L) {
    start <- lubridate::floor_date(start, unit = paste(rnd, "mins"))
    end <- lubridate::ceiling_date(end, unit = paste(rnd, "mins"))
  }
  dur <- lubridate::seconds_to_period(difftime(end, start, units = "secs"))
  # prepare times for output
  start <- format(start, "%Y-%m-%d %H:%M:%S")
  end <- format(end, "%Y-%m-%d %H:%M:%S")
  out$time <- data.frame(start = start, end = end, duration = dur, samples = nrow(rawdat))
  return(out)
}

#' @noRd
read_llh <- function(llh, ...) {
  rawdat <- utils::read.table(llh, ...)
  names(rawdat) <- c("date", "time", "latitude", "longitude", "ellipsoidal_height_m",
                     "Q", "satellites", "sdn_m", "sde_m", "sdu_m", "sdne_m", "sdeu_m",
                     "sdun_m", "age_s", "ratio")
  return(rawdat)
}
