% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_ef_geom.R
\name{as_ef_geom}
\alias{as_ef_geom}
\title{Convert sf geometries to points compatible with Emlid Flow import.}
\usage{
as_ef_geom(x)
}
\arguments{
\item{x}{An sf object.}
}
\value{
An sf object with type POINT or MULTIPOINT.
}
\description{
Convert sf geometries to points compatible with Emlid Flow import.
}
\details{
A wrapper for sf::st_cast() that tries to convert the original geometry to a suitable
(multi)point representation.
}
\examples{
outer <- matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2, byrow = TRUE)
hole1 <- matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2, byrow = TRUE)
hole2 <- matrix(c(5, 5, 5, 6, 6, 6, 6, 5, 5, 5), ncol = 2, byrow = TRUE)
poly <- sf::st_polygon(list(outer, hole1, hole2))
as_ef_geom(poly)  # returns nodes of outer, omitting holes
}
