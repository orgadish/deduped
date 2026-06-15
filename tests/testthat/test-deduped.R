test_that("deduped(f) runs only on deduplicated values", {
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

test_that("deduped(f) early-exits on length-0 and length-1 inputs", {
  n <- 0L
  f <- function(x) { n <<- n + 1L; x }

  deduped(f)(character(0))
  expect_equal(n, 1L)

  deduped(f)("a")
  expect_equal(n, 2L)
})

test_that("deduped(f) early-exits when there is no duplication", {
  n <- 0L
  f <- function(x) { n <<- n + 1L; x }

  deduped(f)(c("a", "b", "c"))
  expect_equal(n, 1L)
})

test_that("deduped(f) returns the data in the same order", {
  x <- c(1, 3, 1, 2, 2, 1)
  pass_through <- \(i) i
  expect_equal(deduped(pass_through)(x), x)
})

test_that("deduped(f) works on unnamed lists", {
  x <- list("ABC", "DEF", "ABC")
  expect_equal(
    deduped(tolower)(x),
    tolower(x)
  )
})

test_that("deduped(f) preserves names on named vectors", {
  x <- c(a = "ABC", b = "dEf", a = "ABC")
  expect_identical(
    deduped(tolower)(x),
    tolower(x)
  )
})

test_that("deduped(f) preserves names on named lists", {

  x <- list(p = "ABC", q = "DEF", r = "ABC")

  # tolower() does not preserve names on a list.
  list_tolower <- function(x) lapply(x, tolower)

  expect_identical(
    deduped(list_tolower)(x),
    list_tolower(x)
  )
})

test_that("deduped(f) drops names on named lists when f drops names", {
  # tolower() does not preserve names on lists.
  x <- list(p = "ABC", q = "DEF", p = "ABC")
  expect_identical(
    deduped(tolower)(x),
    tolower(x)
  )
})

test_that("deduped(f) preserves class from f's output", {
  add_class <- function(x) structure(tolower(x), class = "my_class")

  x <- c("A", "B", "A")
  expect_identical(
    deduped(add_class)(x),
    add_class(x)
  )
})

test_that("deduped(f) preserves attributes added by f, e.g. fs::path", {
  skip_if_not_installed("fs")

  expect_identical(
    deduped(fs::path)("x", "y"),
    fs::path("x", "y")
  )
})

test_that("deduped(f) preserves non-name attributes on x", {
  x <- c("ABC", "ABC")
  attr(x, "test") <- TRUE
  expect_false(is.vector(x))
  expect_equal(
    deduped(tolower)(x),
    tolower(x)
  )
})


test_that("deduped(f) warns on matrices or data frames", {
  pass_through <- \(i) i

  expect_warning(deduped(pass_through)(matrix(1:10)))
  expect_warning(deduped(pass_through)(x = data.frame(1:10)))
})

test_that("deduped(f) fails on functions that change length", {
  expect_error(
    deduped(min)(c(1:10, 1L)),
    regexp = "reduced 10 unique value\\(s\\) to 1"
  )

  # Note: No error if the input has no duplication, due to early exit path.
  expect_no_error(
    deduped(min)(1:10)
  )
})

test_that("deduped(f, verbose=TRUE) prints reduction info", {
  x <- c("A", "B", "A", "A")
  expect_message(
    deduped(tolower, verbose = TRUE)(x),
    regexp = "4 value\\(s\\) reduced to 2 unique"
  )
})

test_that("deduped(f) respects deduped.verbose option", {
  x <- c("A", "B", "A", "A")
  withr::with_options(
    list(deduped.verbose = TRUE),
    expect_message(
      deduped(tolower)(x),
      regexp = "4 value\\(s\\) reduced to 2 unique"
    )
  )
})

test_that("deduped(f, verbose=FALSE) suppresses messages even when option is TRUE", {
  x <- c("A", "B", "A", "A")
  withr::with_options(
    list(deduped.verbose = TRUE),
    expect_no_message(
      deduped(tolower, verbose = FALSE)(x)
    )
  )
})

test_that("deduped(f, verbose=TRUE) messages on all early exit paths", {
  expect_message(
    deduped(tolower, verbose = TRUE)(character(0)),
    regexp = "1 or fewer elements"
  )
  expect_message(
    deduped(tolower, verbose = TRUE)("A"),
    regexp = "1 or fewer elements"
  )
  expect_message(
    deduped(tolower, verbose = TRUE)(c("A", "B", "C")),
    regexp = "no duplication found"
  )
})
