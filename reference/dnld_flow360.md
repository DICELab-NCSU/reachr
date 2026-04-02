# Download Emlid Flow360 projects

Download Emlid Flow360 projects

## Usage

``` r
dnld_flow360(
  dir = "~/Downloads",
  overwrite = FALSE,
  usr = Sys.getenv("EMLID_USER"),
  pwd = Sys.getenv("EMLID_PASSWORD"),
  mult = 1,
  scroll_step = 250,
  max_scrolls = 100
)
```

## Arguments

- dir:

  Directory where the downloaded csv files should be saved.

- overwrite:

  Logical, whether or not to overwrite existing files with the same
  name. NOT YET IMPLEMENTED.

- usr:

  Emlid credential username.

- pwd:

  Emlid credential password.

- mult:

  Multiplier of default wait times.

- scroll_step:

  Pixel distance to move when scrolling down.

- max_scrolls:

  Maximum number of scroll movements to attempt.

## Value

(Invisible) Files will be downloaded to the specified directory.

## Examples

``` r
if (FALSE) { # \dontrun{
dnld_flow360(dir = "~/Downloads")
} # }
```
