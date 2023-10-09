test_that("dedup(f) runs only on deduplicated values", {
  test_dedup.ncalls <<- 0
  f <- function(ii) for(i in ii) test_dedup.ncalls <<- test_dedup.ncalls + 1

  x <- c(1, 1, 1, 2, 3)
  deduped(f)(x)
  expect_equal(test_dedup.ncalls, 3)

  test_dedup.ncalls <<- 0
  x <- 1:5
  deduped(f)(x)
  expect_equal(test_dedup.ncalls, 5)
})
