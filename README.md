
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deduped

<!-- badges: start -->
<!-- badges: end -->

The goal of `deduped` is to provide utility functions that make it
easier to speed up vectorized functions (`deduped()`) or map functions
(`deduped_map()`) when the arguments contain significant duplication.

One particular use case of `deduped()` that I come across a lot is when
using `basename()` and `dirname()` on the `file_path` column after
reading multiple CSVs (e.g. with
`readr::read_csv(..., id="file_path")`). `basename()` and `dirname()`
are surprisingly slow (especially on Windows), and most of the column is
duplicated.

## Installation

You can install the development version of `deduped` like so:

``` r
if(!requireNamespace("remotes")) install.packages("remotes")

remotes::install_github("orgadish/dedup")
```

## Examples

``` r
library(deduped)

slow_func <- function(x) {
  for (i in x) {
    Sys.sleep(0.001)
  }
}

# deduped()
unique_vec <- sample(LETTERS, 10)
unique_vec
#>  [1] "O" "A" "E" "C" "K" "F" "D" "S" "V" "G"

duplicated_vec <- sample(rep(unique_vec, 100))
length(duplicated_vec)
#> [1] 1000

system.time({
  y1 <- slow_func(duplicated_vec)
})
#>    user  system elapsed 
#>   0.026   0.019   1.268
system.time({
  y2 <- deduped(slow_func)(duplicated_vec)
})
#>    user  system elapsed 
#>   0.115   0.012   0.141
all(y1 == y2)
#> [1] TRUE


# deduped_map()
unique_list <- purrr::map(1:5, function(j) sample(LETTERS, j, replace = TRUE))
unique_list
#> [[1]]
#> [1] "I"
#> 
#> [[2]]
#> [1] "A" "W"
#> 
#> [[3]]
#> [1] "F" "C" "I"
#> 
#> [[4]]
#> [1] "I" "X" "Y" "P"
#> 
#> [[5]]
#> [1] "T" "H" "L" "R" "B"

duplicated_list <- sample(rep(unique_list, 100)) # Create a duplicated list
length(duplicated_list)
#> [1] 500

system.time({
  z1 <- purrr::map(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.040   0.025   1.916
system.time({
  z2 <- deduped_map(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.020   0.008   0.048

all.equal(z1, z2)
#> [1] TRUE
```

## `file_path` Example

``` r
# Create multiple CSVs to read
tf <- tempfile()
dir.create(tf)

# Duplicate mtcars 10,000x and write 1 CSV for each value of `am`
duplicated_mtcars <- dplyr::slice(mtcars, rep(1:nrow(mtcars), 10000))
invisible(sapply(
  dplyr::group_split(duplicated_mtcars, am),
  function(k) {
    file_name <- paste0("mtcars_", unique(k$am), ".csv")
    readr::write_csv(k, file.path(tf, file_name))
  }
))

duplicated_mtcars_from_files <- readr::read_csv(
  list.files(tf, full.names = TRUE),
  id = "file_path"
)
#> Rows: 320000 Columns: 12
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> dbl (11): mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
duplicated_mtcars_from_files
#> # A tibble: 320,000 × 12
#>    file_path     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <chr>       <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 /var/folde…  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  2 /var/folde…  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  3 /var/folde…  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  4 /var/folde…  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  5 /var/folde…  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  6 /var/folde…  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#>  7 /var/folde…  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#>  8 /var/folde…  17.8     6  168.   123  3.92  3.44  18.9     1     0     4     4
#>  9 /var/folde…  16.4     8  276.   180  3.07  4.07  17.4     0     0     3     3
#> 10 /var/folde…  17.3     8  276.   180  3.07  3.73  17.6     0     0     3     3
#> # ℹ 319,990 more rows

system.time({
  df1 <- dplyr::mutate(duplicated_mtcars_from_files,
    file_name = basename(file_path)
  )
})
#>    user  system elapsed 
#>   0.080   0.001   0.081
system.time({
  df2 <- dplyr::mutate(duplicated_mtcars_from_files,
    file_name = deduped(basename)(file_path)
  )
})
#>    user  system elapsed 
#>   0.006   0.000   0.007

all.equal(df1, df2)
#> [1] TRUE

unlink(tf)
```
