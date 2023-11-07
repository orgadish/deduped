#' Apply a function to each _unique_ element
#'
#' @description
#' DEPRECATED as of deduped 0.2.0.
#'
#' Please use `deduped(lapply)()` or `deduped(purrr::map)()` instead.
#'
#' @inheritParams purrr::map
#'
#' @return
#' A list whose length is the same as the length of the input,
#' matching the output of [purrr::map()].
#'
#' @seealso [deduped()]
#'
#' @export
deduped_map <- function(.x, .f, ..., .progress = FALSE) {
  warning(paste(
    "`deduped_map(...)` was deprecated in deduped 0.2.0.\n",
    "\U02139 Please use `deduped(purrr::map)(...)` instead."
  ))
  if (!requireNamespace("purrr", quietly = TRUE)) {
    stop("`purrr` must be installed to use `deduped_map()`.")
  }

  deduped(purrr::map)(.x, .f, ..., .progress = .progress)
}
