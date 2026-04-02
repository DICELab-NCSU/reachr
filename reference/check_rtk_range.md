# Check that points or area of interest are within range of proposed RTK base.

Check that points or area of interest are within range of proposed RTK
base.

## Usage

``` r
check_rtk_range(
  rover,
  base,
  local_crs = getOption("local_crs"),
  range = getOption("lora_range", 8000),
  plot = TRUE
)
```

## Arguments

- rover:

  sf object. Point(s) or polygon(s) containing the area of interest
  where the rover will be used.

- base:

  sf object. A point containing the proposed coordinates of the RTK
  base.

- local_crs:

  String. A projected coordinate reference system, either an EPSG code,
  WKT, or proj4string.

- range:

  Numeric. The nominal range of the LoRa signal in meters, defaults to
  8000 m (=8 km).

- plot:

  Logical. Whether or not

## Value

Logical, also a message reporting the result and (optionally) a ggplot.
