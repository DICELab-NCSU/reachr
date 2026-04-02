# Summarize LLH log file to aid download of CORS/VRS corrections

Summarize LLH log file to aid download of CORS/VRS corrections

## Usage

``` r
llh_summary(llh, rnd = 0, ...)
```

## Arguments

- llh:

  File path to .LLH log file

- rnd:

  Number of minutes to round to on both ends of the logging duration
  (see Details)

- ...:

  Additional arguments passed to utils::read.table()

## Value

A list containing the average logged position and position statistics.

## Details

The 'rnd' argument helps pad the logging interval to ensure that the VRS
data include the entire logging duration. A value of 0 will not pad
either the start or end times, resulting in an exact start time and
duration of the LLH log. Positive values will ceiling round the start
time and floor round the stop time to the number of minutes specified by
the user. For example, an interval of 10:28:53-13:56:23 will round as
follows: rnd = 0: 10:28:53-13:56:23, a duration of 03:28:30 rnd = 1:
10:28:00-13:57:00, a duration of 03:29:00 rnd = 15: 10:15:00-14:00:00, a
duration of 04:15:00 For additional information on rounding behaviors,
see ?lubridate::round_date.

## Examples

``` r
if (FALSE) { # \dontrun{
llh_summary(llh = "path/to/file.llh")
} # }
```
