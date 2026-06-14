#' Deduplicate a vectorized function to act on _unique_ elements
#'
#' @description
#' Converts a vectorized function into one that only performs the computations
#' on unique values in the first argument. The result is then expanded so that
#' it is the same as if the computation was performed on all elements.
#'
#' Note: This only works with functions that preserve length and order.
#'
#' @details
#' We make a best effort to preserve the two main cases for named inputs:
#' 1. If `f()` drops names, names are dropped in the output.
#' 2. Otherwise, we preserve the names from the input `x`.
#' We cannot reliably re-expand the names from the deduped output, since
#' duplicate values would always map back to their first occurrence's name.
#'
#' @param f A length-preserving, order-preserving function that accepts a vector
#'  or list as its first input.
#' @param verbose If `TRUE`, prints the number of unique values and reduction
#'  percentage on each call. If `NULL` (default), reads
#'  `getOption("deduped.verbose", FALSE)` at call time, so setting
#'  `options(deduped.verbose = TRUE)` enables it for the entire session.
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
deduped <- function(f, verbose = NULL) {
  # Ensure f is a function.
  f <- match.fun(f)

  function(x, ...) {
    # Resolve verbose at runtime of the function, not when deduped() is first
    # called: explicit argument to deduped() takes priority,
    # otherwise check the session option, otherwise default to FALSE.
    .verbose <- if (!is.null(verbose)) {
      verbose
    } else {
      getOption("deduped.verbose", default = FALSE)
    }

    # collapse::funique() and collapse::fmatch() are faster than the base
    # equivalents, but behave differently on lists.
    if (inherits(x, "list")) {
      unique_fn <- unique
      match_fn <- match
    }

    # Deduped only works on atomic vectors or lists, but using is.vector() is
    # too restrictive since it fails on a vector with attributes. Instead we
    # just exclude matrices and arrays.
    else if (is.atomic(x) && is.null(dim(x))) {
      unique_fn <- collapse::funique
      match_fn <- collapse::fmatch
    }

    else {
      warning(
        "`deduped(f)(x)` only works on atomic vectors or list inputs.\n",
        "Proceeding with f(x, ...) directly.",
        call. = FALSE
      )
      return(f(x, ...))
    }

    # If x is trivially short, skip deduplication overhead.
    # Check after the if/else above to prevent data.frames with one column from
    # exiting without a warning.
    if (length(x) <= 1L) {
      if (isTRUE(.verbose))
        message("deduped: input has 1 or fewer elements, called f(x) directly.")
      return(f(x, ...))
    }

    ux <- unique_fn(x)

    # If there is no duplication, avoid the re-expansion overhead by calling
    # on the original values to minimize the case where `ux` is any different,
    # e.g. if attributes changed.
    if (length(ux) == length(x)) {
      if (isTRUE(.verbose))
        message("deduped: no duplication found, called f(x) directly.")
      return(f(x, ...))
    }

    # Since unique may drop names, restore first-occurrence names
    names(ux) <- names(x)[match_fn(ux, x)]  # Note: Different match than below

    uf <- f(ux, ...)

    # Check for functions that reduce length by comparing ux/ug.
    # There are some cases that this won't catch, but uf[match(x, ux)] results
    # in NAs which mean we can't check the final length directly.
    if(length(uf) != length(ux))
      stop(sprintf(
          "deduped() requires a length-preserving function, but f reduced %d unique value(s) to %d.",
        length(ux), length(uf)
      ))

    out <- uf[match_fn(x, ux)]


    # Restore attributes from uf (what f produced), which covers whole-vector
    # attributes like `class` and `levels`. Custom per-element attributes from
    # third-party packages can't be handled generically here — if f produces
    # any, they will reflect only the unique values rather than the full
    # expanded output.
    attrs <- attributes(uf)

    # For names: since we restore names to ux before calling f, names(uf)
    # correctly reflects whether f preserves names. If f drops names we drop
    # them too; otherwise we use x's original names since match-based
    # re-expansion is unreliable for duplicate values.
    attrs$names <- if (!is.null(names(uf))) names(x) else NULL

    attributes(out) <- attrs

    if (isTRUE(.verbose)) {
      message(sprintf(
        "deduped: %d value(s) reduced to %d unique (%.1f%% reduction).",
        length(x), length(ux), 100 * (1 - length(ux) / length(x))
      ))
    }

    out
  }
}
