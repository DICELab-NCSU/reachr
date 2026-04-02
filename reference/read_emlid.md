# Read files produced by Emlid software as simple features

Read files produced by Emlid software as simple features

## Usage

``` r
read_emlid(
  file,
  format = c("guess", "shp", "csv", "csv_penzd", "dxf", "pos"),
  crs = NULL,
  drop_z = FALSE,
  ...
)
```

## Arguments

- file:

  string. Path to file containing spatial data.

- format:

  string. The file format of the data. Defaults to guessing based on the
  file extension.

- crs:

  string. The coordinate reference system for the spatial data, supplied
  as an EPSG code, WKT, or proj4string.

- drop_z:

  logical, whether or not to drop the z/vertical dimension from points.
  Defaults to FALSE.

- ...:

  passed to function that reads in the datafile

## Value

object of class sf
