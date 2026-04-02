# Check if sf geometry is suitable for importing into Emlid Flow

Check if sf geometry is suitable for importing into Emlid Flow

## Usage

``` r
check_ef_geom(x)
```

## Arguments

- x:

  An sf object.

## Value

logical. TRUE indicates that current geometry type is compatible for
import.

## Details

Emlid Flow currently supports only (multi)point geometries.

## See also

[`as_ef_geom()`](https://dicelab-ncsu.github.io/reachr/reference/as_ef_geom.md)
