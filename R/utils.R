#' Utility functions
#' @noRd
clean_firefox_downloads <- function(download_dir) {
  files <- list.files(download_dir, pattern = "\\.csv$", full.names = FALSE)

  # Pattern: extract base name and optional number
  pattern <- "^(.+?)(\\((\\d+)\\))?\\.csv$"
  matches <- regexec(pattern, files)
  parts <- regmatches(files, matches)

  file_info <- data.frame(
    filename = files,
    base = vapply(parts, function(x) if (length(x) > 1) x[2] else NA_character_, character(1)),
    version = vapply(parts, function(x) if (length(x) > 3 && nzchar(x[3])) as.integer(x[4]) else 0L, integer(1)),
    stringsAsFactors = FALSE
  )

  file_info <- file_info[!is.na(file_info$base), ]

  library(dplyr)
  library(digest)

  file_info <- file_info %>%
    group_by(base) %>%
    arrange(version, .by_group = TRUE) %>%
    mutate(keep = version == max(version))

  for (base_name in unique(file_info$base)) {
    group <- filter(file_info, base == base_name)

    # Skip if there's only one file (no duplicates)
    if (nrow(group) == 1) next

    newest <- filter(group, keep == TRUE)
    original <- filter(group, version == 0)

    newest_path <- file.path(download_dir, newest$filename)
    original_path <- if (nrow(original) > 0) file.path(download_dir, original$filename) else NULL

    # If original file exists, compare contents
    if (!is.null(original_path) && file.exists(original_path)) {
      hash_orig <- digest(original_path, algo = "md5")
      hash_new <- digest(newest_path, algo = "md5")

      if (hash_orig == hash_new) {
        # Files identical → delete newest version
        message("🗑 Duplicate contents — deleting: ", newest$filename)
        file.remove(newest_path)
        next
      } else {
        # Files differ → delete original, rename newest
        message("🗑 Different contents — replacing: ", original$filename, " with ", newest$filename)
        file.remove(original_path)
        file.rename(newest_path, original_path)
      }
    } else {
      # No original — just rename newest
      target_path <- file.path(download_dir, paste0(base_name, ".csv"))
      message("🔄 No original — renaming: ", newest$filename, " → ", target_path)
      file.rename(newest_path, target_path)
    }

    # Delete all older appended versions
    to_delete <- filter(group, !keep & version > 0)
    for (fname in to_delete$filename) {
      message("🗑 Cleaning up older version: ", fname)
      file.remove(file.path(download_dir, fname))
    }
  }
}
