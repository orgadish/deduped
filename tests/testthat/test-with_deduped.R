test_that("with_deduped(f(x)) runs only on deduplicated values", {
  get_ncalls <- function() as.integer(Sys.getenv("ncalls"))
  increment_ncalls <- function() Sys.setenv(ncalls = get_ncalls() + 1L)

  f <- function(ii) {
    for (i in ii) increment_ncalls()
    ii
  }

  withr::with_envvar(
    c(ncalls = 0),
    {
      x <- c(1, 1, 1, 2, 3)
      f(x) |> with_deduped()
      expect_equal(get_ncalls(), 3)
    }
  )

  withr::with_envvar(
    c(ncalls = 0),
    {
      x <- 1:5
      f(x) |> with_deduped()
      expect_equal(get_ncalls(), 5)
    }
  )
})

test_that("with_deduped(f(x, y)) is the same as deduped(f)(x, y) (int)", {
  x <- c(1, 3, 1, 2, 2, 1)
  increment_by_n <- \(x, n) x + n
  inc <- 3
  expect_equal(
    deduped(increment_by_n)(x, inc),
    expect_no_warning(increment_by_n(x, inc) |> with_deduped())
  )

  # Named arguments
  expect_equal(
    deduped(increment_by_n)(x, n=inc),
    expect_no_warning(increment_by_n(x, n=inc) |> with_deduped())
  )
})

test_that("with_deduped(f(x, y)) is the same as deduped(f)(x, y) (char)", {
  x <- LETTERS[c(1, 3, 1, 2, 2, 1)]
  expect_equal(
    deduped(paste0)(x, "X"),
    expect_no_warning(paste0(x, "X") |> with_deduped())
  )
})
