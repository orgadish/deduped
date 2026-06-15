
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deduped

<!-- badges: start -->

[![](https://cranlogs.r-pkg.org/badges/deduped)](https://cran.r-project.org/package=deduped)
<!-- badges: end -->

`deduped` contains one main function `deduped()` which speeds up slow,
vectorized functions by only performing computations on the unique
values of the input and expanding the results at the end. A convenience
wrapper, `with_deduped()`, was added in version 0.3.0 to allow piping an
existing expression.

Note: It only works on functions that preserve length and order.

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

slow_tolower <- function(x) {
  for (i in x) {
    Sys.sleep(0.0005)
  }
  tolower(x)
}
```

### `deduped(...)`

``` r

# Create a vector with significant duplication.
set.seed(1)
unique_vec <- sample(LETTERS, 5)
print(unique_vec)
#> [1] "Y" "D" "G" "A" "B"
duplicated_vec <- sample(rep(unique_vec, 100))
length(duplicated_vec)
#> [1] 500

system.time({  x1 <- slow_tolower(duplicated_vec)  })
#>    user  system elapsed 
#>    0.02    0.00    6.73


system.time({  x2 <- deduped(slow_tolower)(duplicated_vec)  })
#>    user  system elapsed 
#>    0.08    0.00    0.17
all.equal(x1, x2)
#> [1] TRUE

# As of version 0.3.0, you can use `with_deduped()`.
all.equal(x1, slow_tolower(duplicated_vec) |> with_deduped())
#> [1] TRUE
```

### `deduped(lapply)(...)`

`deduped()` can also be combined with `lapply()` or `purrr::map()`.

``` r

set.seed(2)
unique_list <- lapply(1:3, function(j) sample(LETTERS, j, replace = TRUE))
str(unique_list)
#> List of 3
#>  $ : chr "U"
#>  $ : chr [1:2] "O" "F"
#>  $ : chr [1:3] "F" "H" "Q"

# Create a list with significant duplication.
duplicated_list <- sample(rep(unique_list, 50)) 
length(duplicated_list)
#> [1] 150

system.time({  y1 <- lapply(duplicated_list, slow_tolower)  })
#>    user  system elapsed 
#>    0.03    0.00    3.90
system.time({  y2 <- deduped(lapply)(duplicated_list, slow_tolower)  })
#>    user  system elapsed 
#>    0.00    0.00    0.09

all.equal(y1, y2)
#> [1] TRUE
```

### `deduped(fs::path_rel)(...)`

`deduped()` is helpful on slow path functions like `fs::path_rel()`.

``` r

set.seed(3)
top_path <- "x/y/z/"
unique_paths <- paste0(top_path, LETTERS, "/file.csv")
str(unique_paths)
#>  chr [1:26] "x/y/z/A/file.csv" "x/y/z/B/file.csv" "x/y/z/C/file.csv" ...

# Create a list with significant duplication.
dup_paths <- sample(rep(unique_paths, 500)) 
length(dup_paths)
#> [1] 13000

system.time({  y1 <- fs::path_rel(dup_paths, start=top_path)  })
#>    user  system elapsed 
#>    6.16    0.05    6.35
system.time({  y2 <- deduped(fs::path_rel)(dup_paths, start=top_path)  })
#>    user  system elapsed 
#>    0.01    0.00    0.01

all.equal(y1, y2)
#> [1] TRUE
```

### When to use `with_deduped()`

`with_deduped()` is a convenience wrapper for interactive or one-off
use. Because it reconstructs the wrapper function on every call, prefer
`deduped()` directly when calling inside a loop:

``` r
# Good: wrapper is built once
deduped_slow_tolower <- deduped(slow_tolower)
for (x in list_of_vecs) deduped_slow_tolower(x)

# Avoid: wrapper is rebuilt on every iteration
for (x in list_of_vecs) slow_tolower(x) |> with_deduped()
```

### `deduped(..., verbose = TRUE)`

For benchmarking or debugging, pass `verbose = TRUE` to see the
reduction achieved.

``` r
head(
  deduped(slow_tolower, verbose = TRUE)(duplicated_vec)
)
#> deduped: 500 value(s) reduced to 5 unique (99.0% reduction).
#> [1] "y" "a" "b" "y" "d" "d"

# Also available in `with_deduped()`:
head(
  slow_tolower(duplicated_vec) |> with_deduped(verbose = TRUE)
)
#> deduped: 500 value(s) reduced to 5 unique (99.0% reduction).
#> [1] "y" "a" "b" "y" "d" "d"

# Use `options(deduped.verbose)` to enable for the entire session.
options(deduped.verbose = TRUE)
head(
  deduped(slow_tolower)(duplicated_vec)
)
#> deduped: 500 value(s) reduced to 5 unique (99.0% reduction).
#> [1] "y" "a" "b" "y" "d" "d"
```
