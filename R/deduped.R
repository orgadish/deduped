#' Deduplicate a vectorized function to act on _unique_ elements
#'
#' @description
#' Converts a vectorized function into one that only performs the computations
#' on unique values in the first argument. The result is then expanded so that
#' it is the same as if the computation was performed on all elements.
#'
#' Note: This only works with functions that preserve length and order.
#'
#'
#' @param f A length-preserving, order-preserving function that accepts a vector
#'  or list as its first input.
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

    # collapse::funique() and collapse::fmatch() are faster than the base
    # equivalents, but behave differently on lists.
    if (inherits(x, "list")) {
      ux <- unique(x)
      uf <- f(ux, ...)
      out <- uf[match(x, ux)]
    }

    # Deduped only works on atomic vectors or lists, but using is.vector() is
    # too restrictive since it fails on a vector with attributes. Instead we
    # just exclude matrices and arrays.
    else if (is.atomic(x) && is.null(dim(x))) {

      ux <- collapse::funique(x)
      uf <- f(ux, ...)
      out <- uf[collapse::fmatch(x, ux)]
    } else {
      warning(paste(
        "`deduped(f)(x)` only works on atomic vectors or list inputs.",
        "Proceeding with f(x, ...) directly."
      ))
      return(f(x, ...))
    }

    # Check for functions that reduce length by comparing ux/ug.
    # There are some cases that this won't catch, but uf[match(x, ux)] results
    # in NAs which mean we can't check the length directly.
    if(length(uf) != length(ux))
      stop("deduped only works with functions that preserve length.")


    # Since we ensure length is the same, keep attributes.
    attrs <- c(attributes(uf), attributes(x))  # Put uf first to keep those.
    attrs <- attrs[!duplicated(names(attrs))]
    attributes(out) <- attrs

    out
  }
}
