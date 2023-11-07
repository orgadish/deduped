
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deduped

<!-- badges: start -->

[![](https://cranlogs.r-pkg.org/badges/deduped)](https://cran.r-project.org/package=deduped)
<!-- badges: end -->

`deduped` contains one main function `deduped()` which speeds up slow,
vectorized functions by only performing computations on the unique
values of the input and expanding the results at the end.

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

### Basic Example

``` r
library(deduped)
set.seed(0)

slow_func <- function(ii) {
  for (i in ii) {
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
  x1 <- deduped(slow_func)(duplicated_vec)
})
#>    user  system elapsed 
#>   0.097   0.015   0.134
system.time({
  x2 <- slow_func(duplicated_vec)
})
#>    user  system elapsed 
#>   0.032   0.013   1.197
all.equal(x1, x2)
#> [1] TRUE


# deduped() can be combined with lapply() or purrr::map().
unique_list <- lapply(1:5, function(j) sample(LETTERS, j, replace = TRUE))
str(unique_list)
#> List of 5
#>  $ : chr "M"
#>  $ : chr [1:2] "P" "Y"
#>  $ : chr [1:3] "D" "E" "L"
#>  $ : chr [1:4] "B" "I" "J" "N"
#>  $ : chr [1:5] "W" "T" "F" "E" ...

# Create a list with significant duplication.
duplicated_list <- sample(rep(unique_list, 100)) 
length(duplicated_list)
#> [1] 500

system.time({
  y1 <- deduped(lapply)(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.001   0.000   0.018
system.time({
  y2 <- lapply(duplicated_list, slow_func)
})
#>    user  system elapsed 
#>   0.025   0.016   1.756

all.equal(y1, y2)
#> [1] TRUE
```

### `file_path` Example

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
#>   0.104   0.000   0.104
system.time({
  df2 <- dplyr::mutate(
    duplicated_mtcars_from_files,
    file_name = deduped(basename)(file_path)
  )
})
#>    user  system elapsed 
#>   0.010   0.002   0.013

all.equal(df1, df2)
#> [1] TRUE

unlink(tf)
```
