#' Determine target point coordinates from distances to known points
#'
#' @param distances A named vector containing the distances from at least 3 ref_points to the target point.
#' @param ref_points An sf object containing the reference point geometry and a 'Name' column.
#' @param crs A projected coordinate reference system to use in the distance calculations if `ref_points` does not already have a projected CRS.
#' @param ellipse_conf The confidence level for the uncertainty ellipse (0, 1).
#' @param plot Logical, whether to plot the multilateration solution.
#' @param ... Additional options passed to sf::plot()
#'
#' @details
#' This function performs 2D multilateration via optimization. The optimization will fail or give nonsensical results if the units of `distances` and `crs` are not identical. It is strongly recommended to use a projected coordinate system. The standard errors for the x coordinate, y coordinate, and xy positional uncertainty are calculated from the Hessian of the objective function.
#'
#' @returns A list, with xy coordinates in `coords`, measures of coordinate and positional uncertainty in `se`, and the mean ellipsoidal height of the reference points in `mean_ellipsoid_height`.
#' @export
#'
#' @examples
#' d <- c(A = 10.1, B = 7.7, C = 8.0, D = 13.8)
#' ref <- sf::st_as_sf(data.frame(
#'  Name = c("A", "B", "C", "D"),
#'  x = c(0, 10, 0, 18),
#'   y = c(0, 0, 10, 18)
#' ), coords = c("x", "y"), crs = 32613)
#' multilaterate(distances = d, ref_points = ref, ellipse_conf = 0.95)

multilaterate <- function(distances, ref_points, crs = NULL, ellipse_conf = 0.95, plot = TRUE, ...) {
  # Check inputs
  distances <- distances[sort(names(distances))]
  stopifnot(is.numeric(distances), !is.null(names(distances)), ellipse_conf > 0 & ellipse_conf < 1)
  matched_refs <- ref_points[ref_points$Name %in% names(distances), ]
  if (nrow(matched_refs) < 3) {
    stop("At least 3 reference points with matching names are required.")
  }
  # Re-project if necessary
  orig_crs <- sf::st_crs(ref_points)
  if (!is.null(crs)) {
    matched_refs <- sf::st_transform(matched_refs, crs)
  } else {
    if (is.na(sf::st_crs(matched_refs)$units_gdal) || sf::st_crs(matched_refs)$units_gdal != "metre") {
      stop("Reference points must be in a projected CRS (units = metre). Use 'crs' to specify one.")
    }
  }
  # Extract coordinates and match order with distances
  coords <- sf::st_coordinates(matched_refs)
  dists <- distances[matched_refs$Name]
  # Optimization: minimize squared error between supplied and candidate distances
  objective <- function(par) {
    x <- par[1]
    y <- par[2]
    est_dists <- sqrt((coords[, 1] - x)^2 + (coords[, 2] - y)^2)
    sum((est_dists - dists)^2)
  }
  start <- colMeans(coords)
  opt <- stats::optim(start, objective, method = "L-BFGS-B")
  est_xy <- opt$par
  est_point <- sf::st_sfc(sf::st_point(est_xy), crs = sf::st_crs(matched_refs))
  # Transform back to original CRS if needed
  if (!is.null(crs)) {
    est_point <- sf::st_transform(est_point, orig_crs)
  }
  # Coordinates in original CRS
  coords_out <- as.numeric(sf::st_coordinates(est_point))
  names(coords_out) <- c("x", "y")
  # Uncertainty estimation
  H <- numDeriv::hessian(objective, opt$par)

  ellipse <- NULL

  if (det(H) <= 0) {
    warning("Hessian is not positive definite; SEs may be unreliable.")
    se_x <- se_y <- se_xy <- NA
  } else {
    # Residual variance estimate
    rss <- objective(opt$par)
    n <- length(dists)
    sigma2 <- rss / (n - 2)
    cov_matrix <- sigma2 * solve(H / 2)
    se_x <- sqrt(cov_matrix[1, 1])
    se_y <- sqrt(cov_matrix[2, 2])
    se_xy <- sqrt(se_x^2 + se_y^2)
    # compute uncertainty ellipse
    eig <- eigen(cov_matrix)
    chi2_val <- stats::qchisq(ellipse_conf, df = 2)
    axes <- sqrt(eig$values * chi2_val)
    theta <- atan2(eig$vectors[2,1], eig$vectors[1,1])
  }
  if (plot) {
    multilaterate_plot(r = dists, xy = coords, est = est_xy, axes = axes, angle = theta)
  }
  out <- list(
    coords = coords_out,
    se = c(se_x = se_x, se_y = se_y, se_xy = se_xy)
  )
  return(out)
}
