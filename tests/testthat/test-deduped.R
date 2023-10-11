test_that("dedup(f) runs only on deduplicated values", {
  get_ncalls <- function() as.integer(Sys.getenv("ncalls"))
  increment_ncalls <- function() Sys.setenv(ncalls = get_ncalls() + 1L)

  f <- function(ii) for(i in ii) increment_ncalls()

  withr::with_envvar(
    c(ncalls = 0),
    {
      x <- c(1, 1, 1, 2, 3)
      deduped(f)(x)
      expect_equal(get_ncalls(), 3)
    }
  )

  withr::with_envvar(
    c(ncalls = 0),
    {
      x <- 1:5
      deduped(f)(x)
      expect_equal(get_ncalls(), 5)
    }
  )
})
