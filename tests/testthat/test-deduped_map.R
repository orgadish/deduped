test_that("deduped_map warns for deprecation, but works", {
  x <- list("ABC", "ABC")
  expect_warning(deduped_map(x, tolower), "deprecated")
  expect_equal(
    suppressWarnings(deduped_map(x, tolower)),
    deduped(lapply)(x, tolower)
  )
})
