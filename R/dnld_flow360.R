#' Download Emlid Flow360 projects
#'
#' @param dir Directory where the downloaded csv files should be saved.
#' @param overwrite Logical, whether or not to overwrite existing files with the same name. NOT YET IMPLEMENTED.
#' @param usr Emlid credential username.
#' @param pwd Emlid credential password.
#' @param mult Multiplier of default wait times.
#' @param scroll_step Pixel distance to move when scrolling down.
#' @param max_scrolls Maximum number of scroll movements to attempt.
#'
#' @returns (Invisible) Files will be downloaded to the specified directory.
#' @import RSelenium
#' @export
#'
#' @examples
#' \dontrun{
#' dnld_flow360(dir = "~/Downloads")
#' }

dnld_flow360 <- function(dir = "~/Downloads", overwrite = FALSE,
                         usr = Sys.getenv("EMLID_USER"),
                         pwd = Sys.getenv("EMLID_PASSWORD"),
                         mult = 1, scroll_step = 250, max_scrolls = 100) {
  # set browser profile
  fprof <- RSelenium::makeFirefoxProfile(list(
    "browser.download.folderList" = 2L,                           # Use custom dir
    "browser.download.dir" = dir,                                 # Set download path
    "browser.helperApps.neverAsk.saveToDisk" =
      "text/csv,application/csv,application/vnd.ms-excel",        # MIME types to auto-download
    "browser.download.useDownloadDir" = TRUE,                     # Always use dir
    "pdfjs.disabled" = TRUE,                                      # Don't open PDFs in-browser
    "browser.download.manager.showWhenStarting" = FALSE,          # No download popup
    "browser.download.manager.alertOnEXEOpen" = FALSE,
    "browser.download.manager.focusWhenStarting" = FALSE,
    "browser.download.manager.useWindow" = FALSE,
    "browser.download.manager.closeWhenDone" = TRUE,
    "browser.download.manager.showAlertOnComplete" = FALSE,
    "browser.download.manager.scanWhenDone" = FALSE,
    "browser.helperApps.alwaysAsk.force" = FALSE,
    "browser.download.manager.retention" = 0L,
    "browser.download.always_ask_before_handling_new_types" = FALSE,
    "browser.download.panel.shown" = FALSE
  ))

  # create directory, if needed
  if(!dir.exists(dir)) dir.create(dir)

  # start Selenium
  rD <- RSelenium::rsDriver(browser = "firefox", port = 4567L, verbose = FALSE,
                            phantomver = NULL, extraCapabilities = fprof)
  remDr <- rD$client
  # navigate to Emlid Flow360
  remDr$navigate("https://flow360.emlid.com/app/projects/available/")
  Sys.sleep(2 * mult)
  # login
  email_field <- remDr$findElement(using = "css", value = "input[type='email']")
  email_field$sendKeysToElement(list(usr))
  password_field <- remDr$findElement(using = "css", value = "input[type='password']")
  password_field$clickElement()
  password_field$sendKeysToElement(list(pwd))
  login_btn <- remDr$findElement(using = "css", value = "button[type='submit']")
  login_btn$clickElement()
  Sys.sleep(4 * mult)

  # fetch tiles
  downloaded_indices <- character()
  pause <- 1 * mult

  for (i in seq_len(max_scrolls)) {
    message(sprintf("\n🔄 Page %d", i))

    # Scroll down a bit
    remDr$executeScript(sprintf("window.scrollBy(0, %d);", scroll_step))
    Sys.sleep(pause)

    # Get visible tiles
    tiles <- remDr$findElements("css", "div.virtuoso-grid-item")

    # Process only new tiles
    for (tile in tiles) {
      index <- tryCatch(tile$getElementAttribute("data-index")[[1]], error = function(e) NA)
      if (is.na(index) || index %in% downloaded_indices) next

      message(sprintf("📦 Exporting tile with data-index: %s", index))

      # Scroll tile into view
      remDr$executeScript("arguments[0].scrollIntoView(true);", list(tile))
      Sys.sleep(0.5 * mult)

      # Click the "..." dropdown
      dropdown <- tryCatch(
        tile$findElement("css selector", "div[data-testid='dropdown-component']"),
        error = function(e) NULL
      )

      menu_btn <- tryCatch(
        dropdown$findChildElement("css selector", "button"),
        error = function(e) NULL
      )

      if (is.null(menu_btn)) next
      menu_btn$clickElement()
      Sys.sleep(1 * mult)

      # Click "Export"
      export_btn <- tryCatch(remDr$findElement("xpath", "//span[contains(text(), 'Export')]"), error = function(e) NULL)
      if (is.null(export_btn)) next
      export_btn$clickElement()
      Sys.sleep(2 * mult)

      # Click "CSV" radio option
      csv_btn <- tryCatch(
        remDr$findElement("xpath", "//label[contains(., 'CSV')]"),
        error = function(e) NULL
      )
      if (!is.null(csv_btn)) {
        csv_btn$clickElement()
        Sys.sleep(1 * mult)
      }

      # Click "All columns"
      all_cols_btn <- tryCatch(
        remDr$findElement("xpath", "//label[contains(., 'All columns')]"),
        error = function(e) NULL
      )

      if (!is.null(all_cols_btn)) {
        all_cols_btn$clickElement()
        Sys.sleep(1 * mult)
      }

      # Click final "Export" button
      final_export_btn <- tryCatch(
        remDr$findElement("xpath", "//button[@data-testid='button' and normalize-space()='Export']"),
        error = function(e) NULL
      )

      if (!is.null(final_export_btn)) {
        final_export_btn$clickElement()
        Sys.sleep(4 * mult)  # wait for download to start
        downloaded_indices <- c(downloaded_indices, index)
      } else {
        message(sprintf("⚠️ Final Export button not found for tile %s", index))
      }
    }

    # Stop if no new tiles found this scroll
    if (i > 1 && length(downloaded_indices) == prev_count) {
      message("✅ All available tiles processed.")
      break
    }

    prev_count <- length(downloaded_indices)
  }

  # Clean up file names in download directory
  if (overwrite) {
    clean_firefox_download(dir = dir)
  }

  # Close Selenium instance
  message("Closing Selenium server...")
  remDr$close()
  rD$server$stop()
}
