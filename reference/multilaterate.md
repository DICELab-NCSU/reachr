# Determine target point coordinates from distances to known points

Determine target point coordinates from distances to known points

## Usage

``` r
multilaterate(
  distances,
  ref_points,
  crs = NULL,
  ellipse_conf = 0.95,
  plot = TRUE,
  ...
)
```

## Arguments

- distances:

  A named vector containing the distances from at least 3 ref_points to
  the target point.

- ref_points:

  An sf object containing the reference point geometry and a 'Name'
  column.

- crs:

  A projected coordinate reference system to use in the distance
  calculations if `ref_points` does not already have a projected CRS.

- ellipse_conf:

  The confidence level for the uncertainty ellipse (0, 1).

- plot:

  Logical, whether to plot the multilateration solution.

- ...:

  Additional options passed to sf::plot()

## Value

A list, with xy coordinates in `coords`, measures of coordinate and
positional uncertainty in `se`, and the mean ellipsoidal height of the
reference points in `mean_ellipsoid_height`.

## Details

This function performs 2D multilateration via optimization. The
optimization will fail or give nonsensical results if the units of
`distances` and `crs` are not identical. It is strongly recommended to
use a projected coordinate system. The standard errors for the x
coordinate, y coordinate, and xy positional uncertainty are calculated
from the Hessian of the objective function.

## Examples

``` r
d <- c(A = 10.1, B = 7.7, C = 8.0, D = 13.8)
ref <- sf::st_as_sf(data.frame(
 Name = c("A", "B", "C", "D"),
 x = c(0, 10, 0, 18),
  y = c(0, 0, 10, 18)
), coords = c("x", "y"), crs = 32613)
multilaterate(distances = d, ref_points = ref, ellipse_conf = 0.95)

#> $coords
#>        x        y 
#> 7.753330 7.532022 
#> 
#> $se
#>      se_x      se_y     se_xy 
#> 0.5623134 0.5609161 0.7942438 
#> 
```
