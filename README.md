# reachr

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test coverage](https://codecov.io/gh/DICELab-NCSU/reachr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/DICELab-NCSU/reachr?branch=main)
[![R-CMD-check](https://github.com/DICELab-NCSU/reachr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/DICELab-NCSU/reachr/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/reachr)](https://CRAN.R-project.org/package=reachr)
<!-- badges: end -->

The goal of reachr is to provide utilities for working with data produced by 
[Emlid](https://emlid.com/) products, including the Reach RS2(+) GNSS receiver and Emlid 
Studio post-processing software.

## Installation

This package is still in the 'experimental' stage and has not yet been submitted to CRAN. 
You can install the development version of reachr from [GitHub](https://github.com/) with:

``` r
# install.packages(c("remotes"))
remotes::install_github("DICELab-NCSU/reachr")
```

The package can be loaded with:

``` r
library(reachr)
```

## Core utilities
### Load spatial data files

The `read_emlid` function provides a wrapper to import the various file formats for spatial 
data used by Emlid, returning an `sf` object. The function guessed the file format based on 
the file extension.

``` r
mypoints <- read_emlid("path/to/data/mypoints.shp")
```

Not all Emlid file exports include the coordinate reference system (CRS). `read_emlid` warns 
users when a file is imported without a known CRS and allows users to specify the CRS during 
import using standard formats: EPSG codes, WKT, or proj4string.

``` r
mypoints2 <- read_emlid("path/to/data/mypoints2.csv")  # imports with warning
mypoints2 <- read_emlid("path/to/data/mypoints2.csv", crs = 4326)  # sets CRS
```

### Update RTK coordinate to new base position

For some RTK surveys, it is not possible to obtain a precise coordinate for the base position 
prior to collecting points with the rover. It is still possible to collect points using RTK
*relative* to an estimated base position, then update the points to use the correct base 
position (e.g., after PPP post-processing). reachr automates the process of shifting the 
coordinates of rover-collected points to use an updated base position following a tutorial 
post on the [Emlid Community Forum](https://community.emlid.com/t/how-to-correct-collected-points-with-a-new-base-position/31548).

### Miscellaneous utilities

- `ef_geom_check`: checks that only point geometries are used in spatial data object, 
ensuring they can be imported into Emlid Flow
- `as_ef_geom`: attempts to automatically coerce non-point geometries into (multi)point 
geometries that can be imported into Emlid Flow
- `check_rtk_range`: checks that points are within LoRa antenna range for RTK surveying
- `llh_summary`: summarizes the position and duration of .LLH log files

## Planned features
### Prepare .csv file for Emlid Flow import

Importing points from a .csv file into an Emlid Flow project requires following a strict 
column order and naming convention. (As of July 2023, this is incompletely documented in the 
import dialog.) reachr provides helper functions to convert `sf` objects into a correctly-formatted 
.csv file.

## Code of Conduct
  
  Please note that the reachr project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
