#' Deduplicate a vectorized function to act on _unique_ elements
#'
#' @description
#' Converts a vectorized function into one that only performs the computations
#' on unique values in the first argument. The result is then expanded so that
#' it is the same as if the computation was performed on all elements.
#'
#' @param f A function that accepts a vector or list as its first input.
#'
#' @return Deduplicated version of `f`.
#' @export
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
#'   tolower(x)
#' }
#'
#' system.time({
#'   y1 <- slow_func(large_x)
#' })
#'
#' system.time({
#'   y2 <- deduped(slow_func)(large_x)
#' })
#'
#' all(y1 == y2)
deduped <- function(f) {
  # Ensure f is a function.
  f <- match.fun(f)

  function(x, ...) {


    # collapse::funique() is faster than unique(), but behaves differently
    # on lists.
    if (inherits(x, "list"))
    {
      ux <- unique(x)
    } else if (is.vector(x) && is.atomic(x)) {
      ux <- collapse::funique(x)
    } else {
      warning(paste(
        "`deduped(f)(x)` only works on atomic vectors or list inputs.",
        "Proceeding with f(x) directly."
      ))
      return(f(x, ...))
    }

    f(ux, ...)[fastmatch::fmatch(x, ux)]
  }
}
