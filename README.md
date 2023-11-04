
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deduped

<!-- badges: start -->

[![](https://cranlogs.r-pkg.org/badges/deduped)](https://cran.r-project.org/package=deduped)
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

You can install the released version of `deduped` from
[CRAN](https://cran.r-project.org/package=deduped) with:

``` r
install.packages("deduped")
```

And the development version from
[GitHub](https://github.com/orgadish/deduped):

``` r
if(!requireNamespace("remotes")) install.packages("remotes")

remotes::install_github("orgadish/deduped")
```

## Examples

``` r
library(deduped)
set.seed(0)

slow_func <- function(x) {
  for (i in x) {
    Sys.sleep(0.001)
  }
}

# deduped()
unique_vec <- sample(LETTERS, 10)
unique_vec
#>  [1] "N" "Y" "D" "G" "A" "B" "K" "Z" "R" "V"

duplicated_vec <- sample(rep(unique_vec, 100))
length(duplicated_vec)
#> [1] 1000

system.time({
  y1 <- slow_func(duplicated_vec)
})
#>    user  system elapsed 
#>   0.018   0.013   1.218
system.time({
  y2 <- deduped(slow_func)(duplicated_vec)
})
#>    user  system elapsed 
#>   0.117   0.012   0.148
all(y1 == y2)
#> [1] TRUE


# deduped_map()
unique_list <- purrr::map(1:5, function(j) sample(LETTERS, j, replace = TRUE))
unique_list
#> [[1]]
#> [1] "M"
#> 
#> [[2]]
#> [1] "P" "Y"
#> 
#> [[3]]
#> [1] "D" "E" "L"
#> 
#> [[4]]
#> [1] "B" "I" "J" "N"
#> 
#> [[5]]
#> [1] "W" "T" "F" "E" "S"

duplicated_list <- sample(rep(unique_list, 100)) # Create a duplicated list
length(duplicated_list)
#> [1] 500

system.time({
  z1 <- purrr::map(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.030   0.018   1.829
system.time({
  z2 <- deduped_map(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.020   0.010   0.054

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
  id = "file_path",
  show_col_types = FALSE
)
dplyr::count(duplicated_mtcars_from_files, basename(file_path))
#> # A tibble: 2 × 2
#>   `basename(file_path)`      n
#>   <chr>                  <int>
#> 1 mtcars_0.csv          190000
#> 2 mtcars_1.csv          130000

system.time({
  df1 <- dplyr::mutate(
    duplicated_mtcars_from_files,
    file_name = basename(file_path)
  )
})
#>    user  system elapsed 
#>   0.119   0.001   0.119
system.time({
  df2 <- dplyr::mutate(
    duplicated_mtcars_from_files,
    file_name = deduped(basename)(file_path)
  )
})
#>    user  system elapsed 
#>   0.010   0.001   0.012

all.equal(df1, df2)
#> [1] TRUE

unlink(tf)
```
