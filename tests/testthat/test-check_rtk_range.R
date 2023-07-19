rov <- sf::st_as_sf(tibble::tibble(lon = c(-106.003, -106.004), lat = c(38.003, 38.004)), coords = c("lon", "lat"), crs = 4326)
bas1 <- sf::st_as_sf(tibble::tibble(lon = -106, lat = 38), coords = c("lon", "lat"), crs = 4326)
bas2 <- sf::st_as_sf(tibble::tibble(lon = -107, lat = 39), coords = c("lon", "lat"), crs = 4326)

test_that("base within range - meters", {
  expect_true(check_rtk_range(rover = rov, base = bas1, local_crs = 26913, plot = FALSE))
})

test_that("base within range - feet", {
  expect_true(check_rtk_range(rover = rov, base = bas1, local_crs = 2232, plot = FALSE))
})

test_that("base outside range", {
  expect_false(check_rtk_range(rover = rov, base = bas2, local_crs = 26913, plot = FALSE))
})

test_that("warns when local_crs is not projected", {
  expect_error(check_rtk_range(rover = rov, base = bas1, local_crs = 4326, plot = FALSE))
})
