# Summarize Rinex observation file

Summarize Rinex observation file

## Usage

``` r
rinex_summary(rinex)
```

## Arguments

- rinex:

  Path to Rinex observation file (.YYo where YY are the last two digits
  of the observation year).

## Value

A list containing the Rinex version, number of satellites in used from
each constellation, and the observation start/end times.

## Examples

``` r
if (FALSE) { # \dontrun{
rinex_summary(rinex = "path/to/file.25o")
} # }
```
