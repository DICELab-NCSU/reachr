# Update coordinates to use a new base position

Update coordinates to use a new base position

## Usage

``` r
update_base(points, newbase, base_row = NULL, destfile = NULL)
```

## Arguments

- points:

  path to a file produced using the Emlid Flow csv export tool

- newbase:

  path to a file containing the updated base coordinates

- base_row:

  (optional) row containing the updated base coordinates if newbase
  contains multiple points

- destfile:

  (optional) path to write a csv file containing corrected points

## Value

a tibble following the formatting conventions of Emlid Flow csv export
