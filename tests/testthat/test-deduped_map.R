test_that("deduped_map(f) runs only on deduplicated values", {
  get_ncalls <- function() as.integer(Sys.getenv("ncalls"))
  increment_ncalls <- function() Sys.setenv(ncalls = get_ncalls() + 1L)

  f <- function(i) increment_ncalls()

  x <- list(
    c(1, 2),
    "A",
    data.frame(x = "A"),
    data.frame(y = 1)
  )
  xr <- rep(x, 5)

  withr::with_envvar(
    c(ncalls = 0),
    {
      deduped_map(xr, f)
      expect_equal(get_ncalls(), length(x))
    }
  )

  withr::with_envvar(
    c(ncalls = 0),
    {
      deduped_map(x, f)
      expect_equal(get_ncalls(), length(x))
    }
  )
})

test_that("deduped_map(f) returns the data in the same order", {
  x <- list(
    c(1, 2),
    "A",
    data.frame(x = "A"),
    data.frame(y = 1)
  )
  xr <- rep(x, 5)
  pass_through <- function(i) i
  expect_equal(deduped_map(xr, pass_through), xr)
})
