#' Utility functions

clean_firefox_download <- function(download_dir, base_filename) {
  base_path <- file.path(download_dir, base_filename)

  # Construct the appended filename pattern e.g., "export (1).csv"
  file_ext <- tools::file_ext(base_filename)
  file_base <- tools::file_path_sans_ext(base_filename)
  appended_path <- file.path(download_dir, paste0(file_base, " (1).", file_ext))

  # If appended file doesn't exist, nothing to do
  if (!file.exists(appended_path)) {
    message("No appended duplicate file found.")
    return(invisible(NULL))
  }

  if (!file.exists(base_path)) {
    # Original doesn't exist, so rename appended to original
    file.rename(appended_path, base_path)
    message("Original file missing; renamed appended file to original name.")
    return(invisible(NULL))
  }

  # Compare files byte-wise
  base_hash <- digest::digest(file = base_path, algo = "md5")
  appended_hash <- digest::digest(file = appended_path, algo = "md5")

  if (base_hash == appended_hash) {
    # Files identical: remove appended
    file.remove(appended_path)
    message("Duplicate file detected; removed appended file.")
  } else {
    # Files differ: replace original with appended
    file.remove(base_path)
    file.rename(appended_path, base_path)
    message("Different file detected; replaced original with appended file.")
  }
}

load_tiles <- function(remDr, css_selector = "div.virtuoso-grid-item",
                       pause = 2, scroll_step = 500, max_scrolls = 100) {
  tile_map <- list()

  for (i in seq_len(max_scrolls)) {
    # Scroll down a little bit
    remDr$executeScript(sprintf("window.scrollBy(0, %d);", scroll_step))
    Sys.sleep(pause)

    # Find currently visible tiles
    tiles <- remDr$findElements(using = "css", value = css_selector)

    # Add new tiles by unique data-index
    new_tiles_added <- 0
    for (tile in tiles) {
      index <- tryCatch(tile$getElementAttribute("data-index")[[1]], error = function(e) NA)
      if (!is.na(index) && !(index %in% names(tile_map))) {
        tile_map[[index]] <- tile
        new_tiles_added <- new_tiles_added + 1
      }
    }

    message(sprintf("Scroll %d: %d new tiles, %d total collected",
                    i, new_tiles_added, length(tile_map)))

    # Break if no new tiles added this round
    if (new_tiles_added == 0) {
      message("✅ All tiles loaded.")
      break
    }
  }

  # Return the list of tile WebElements
  unname(tile_map)
}
