
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deduped

<!-- badges: start -->
<!-- badges: end -->

The goal of `deduped` is to provide a utility function that makes it
easier to speed up functions that are commonly run on vectors with
significant duplication.

## Installation

You can install the development version of deduped like so:

``` r
if(!requireNamespace("remotes")) install.packages("remotes")

remotes::install_github("orgadish/dedup")
```

## Example

``` r
library(deduped)
x <- sample(LETTERS, 10)
x
#>  [1] "Q" "T" "B" "G" "W" "D" "Z" "K" "U" "J"

large_x <- sample(rep(x, 100))
length(large_x)
#> [1] 1000

slow_func <- function(x) for(i in x) {Sys.sleep(0.001)}

system.time({y <- slow_func(large_x)})
#>    user  system elapsed 
#>   0.008   0.007   1.151
system.time({y2 <- dedup(slow_func)(large_x)})
#>    user  system elapsed 
#>   0.088   0.010   0.119
all(y == y2)
#> [1] TRUE
```
