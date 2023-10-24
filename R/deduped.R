#' Deduplicate a vectorized function to act on _unique_ elements
#'
#' @description
#' Converts a vectorized function into one that only performs the computations
#' on unique values in the first argument. The result is then expanded so that
#' it is the same as if the computation was performed on all elements.
#'
#' @param f Function to deduplicate.
#'
#' @return Deduplicated function.
#' @export
#'
#' @seealso [deduped_map()], a deduplicated version of [purrr::map()].
#'
#' @examples
#'
#' x <- sample(LETTERS, 10)
#' x
#'
#' large_x <- sample(rep(x, 10))
#' length(large_x)
#'
#' slow_func <- function(x) {
#'   for (i in x) {
#'     Sys.sleep(0.001)
#'   }
#' }
#'
#' system.time({
#'   y1 <- slow_func(large_x)
#' })
#' system.time({
#'   y2 <- deduped(slow_func)(large_x)
#' })
#'
#' all(y1 == y2)
deduped <- function(f) {
  function(x, ...) {
    ux <- collapse::funique(x)
    f(ux, ...)[fastmatch::fmatch(x, ux)]
  }
}
