#' @noRd

read_emlid_pos <- function(file){
  raw <- readLines(file)
  metadata <- tibble::tribble(~attribute, ~value,
                              "program", stringr::str_extract(raw[1], pattern = "\\: (.*$)", group = TRUE),
                              "file_obs", stringr::str_extract(raw[2], pattern = "\\: (.*$)", group = TRUE),
                              "file_nav", stringr::str_extract(raw[3], pattern = "\\: (.*$)", group = TRUE),
                              "file_ref", stringr::str_extract(raw[4], pattern = "\\: (.*$)", group = TRUE),
                              "obs_start", stringr::str_extract(raw[5],
                                                                pattern = "\\: ([0-9/]{10} [0-9:.]{10} [A-Z]+)", group = TRUE),
                              "obs_end", stringr::str_extract(raw[6],
                                                              pattern = "\\: ([0-9/]{10} [0-9:.]{10} [A-Z]+)", group = TRUE),
                              "ref_lon", stringr::str_extract(raw[7],
                                                              pattern = "\\: [0-9.]+([- ][0-9.]+)", group = TRUE),
                              "ref_lat", stringr::str_extract(raw[7],
                                                              pattern = "\\: ([0-9.]+)", group = TRUE),
                              "ref_ellhgt", stringr::str_extract(raw[7],
                                                                 pattern = "([0-9.]+$)", group = TRUE))
  pos <- raw[-(1:10)]
  pos <- lapply(stringr::str_split(pos, pattern = "  "), stringr::str_trim)
  pos <- dplyr::bind_rows(lapply(pos, tibble::as_tibble_row, .name_repair = "unique"))
  names(pos) <- c("datetime", "latlon_dd", "ellipsoidal_height_m", "Q", "ns",
                  "sdN_m", "sdE_m", "sdU_m", "sdNE_m", "sdEU_m", "sdUN_m", "age_s", "ratio")
  pos$datetime <- lubridate::ymd_hms(pos$datetime, tz = "UTC")
  coord <- dplyr::bind_rows(lapply(stringr::str_split(pos$latlon_dd, pattern = " ", n = 2),
                                   as_tibble_row, .name_repair = "unique"))
  names(coord) <- c("latitude_dd", "longitude_dd")
  pos$latitude_dd <- as.numeric(coord$latitude_dd)
  pos$longitude_dd <- as.numeric(coord$longitude_dd)
  pos$ellipsoidal_height_m <- as.numeric(pos$ellipsoidal_height_m)
  pos$sdN_m <- as.numeric(pos$sdN_m)
  pos$sdE_m <- as.numeric(pos$sdE_m)
  pos$sdU_m <- as.numeric(pos$sdU_m)
  out <- pos[, c("datetime", "latitude_dd", "longitude_dd", "ellipsoidal_height_m",
                 "sdN_m", "sdE_m", "sdU_m")]
  out$obs_start <- metadata[5, ]$value
  out$obs_end <- metadata[6, ]$value
  out$ref_lat <- metadata[8, ]$value
  out$ref_lon <- metadata[7, ]$value
  out$ref_ellhgt <- metadata[9, ]$value
  return(out)
}
