
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

### Setup

``` r
library(deduped)
set.seed(0)

slow_func <- function(ii) {
  for (i in ii) {
    Sys.sleep(0.0005)
  }
}
```

### `deduped()`

``` r

unique_vec <- sample(LETTERS, 5)
unique_vec
#> [1] "N" "Y" "D" "G" "A"

# Create a vector with significant duplication.
duplicated_vec <- sample(rep(unique_vec, 50))
length(duplicated_vec)
#> [1] 250

system.time({  x1 <- slow_func(duplicated_vec)  })
#>    user  system elapsed 
#>    0.00    0.00    3.87
system.time({  x2 <- deduped(slow_func)(duplicated_vec)  })
#>    user  system elapsed 
#>    0.07    0.05    0.19

all.equal(x1, x2)
#> [1] TRUE
```

### `deduped(lapply)()`

`deduped()` can also be combined with `lapply()` or `purrr::map()`.

``` r

unique_list <- lapply(1:3, function(j) sample(LETTERS, j, replace = TRUE))
str(unique_list)
#> List of 3
#>  $ : chr "E"
#>  $ : chr [1:2] "L" "O"
#>  $ : chr [1:3] "N" "O" "Q"

# Create a list with significant duplication.
duplicated_list <- sample(rep(unique_list, 50)) 
length(duplicated_list)
#> [1] 150

system.time({  y1 <- lapply(duplicated_list, slow_func)  })
#>    user  system elapsed 
#>    0.00    0.00    4.66
system.time({  y2 <- deduped(lapply)(duplicated_list, slow_func)  })
#>    user  system elapsed 
#>     0.0     0.0     0.1

all.equal(y1, y2)
#> [1] TRUE
```

### Specific example: `deduped(basename)()` on file paths

*Note: Times shown below are based on running R 4.3.2 on Windows 10, for
which `basename()` is known to be slow: [Bug
18597](https://bugs.r-project.org/show_bug.cgi?id=18597).*

``` r
# Create multiple CSVs to read
tf <- withr::local_tempdir()

# Duplicate mtcars 10,000x and write 1 CSV for each value of `am`
duplicated_mtcars <- dplyr::slice(mtcars, rep(1:nrow(mtcars), 10000))
invisible(sapply(
  dplyr::group_split(duplicated_mtcars, am),
  function(dat) {
    file_name <- paste0("mtcars_", unique(dat$am), ".csv")
    readr::write_csv(dat, file.path(tf, file_name))
  }
))

# Read the separate files back in.
mtcars_files <- list.files(tf, full.names = TRUE)
length(mtcars_files)
#> [1] 2

duplicated_mtcars_from_files <- readr::read_csv(
  mtcars_files,
  id = "file_path",
  show_col_types = FALSE
)
dplyr::count(duplicated_mtcars_from_files, basename(file_path))
#> # A tibble: 2 × 2
#>   `basename(file_path)`      n
#>   <chr>                  <int>
#> 1 mtcars_0.csv          190000
#> 2 mtcars_1.csv          130000

# Original: slow
system.time({
  df1 <- dplyr::mutate(
    duplicated_mtcars_from_files,
    file_name = basename(file_path)
  )
})
#>    user  system elapsed 
#>    2.94    0.04    2.97

# Deduped: fast
system.time({
  df2 <- dplyr::mutate(
    duplicated_mtcars_from_files,
    file_name = deduped(basename)(file_path)
  )
})
#>    user  system elapsed 
#>       0       0       0

all.equal(df1, df2)
#> [1] TRUE
```
