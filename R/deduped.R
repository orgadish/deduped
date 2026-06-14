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
#' Names are taken from the input `x` rather than re-expanded from `f`'s output
#' on the unique values. This means value-based renaming (e.g.
#' `setNames(x, paste0("out_", x))`) is preserved correctly, but position-based
#' renaming (e.g. `setNames(x, seq_along(x))`) will produce incorrect results
#' since `f` is called on the unique values only. If `f` renames by position,
#' call it directly rather than wrapping with `deduped()`.
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

    # If x is trivially short, skip deduplication overhead.
    if (length(x) <= 1L)
      return(f(x, ...))

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

    ux <- unique_fn(x)

    # If there is no duplication, avoid the re-expansion overhead by calling
    # on the original values to minimize the case where `ux` is any different,
    # e.g. if attributes changed.
    if(length(ux) == length(x))
      return(f(x, ...))

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
    # attributes like `class` and `levels`. For names, we use x's original names
    # rather than re-expanding uf's names: most functions either preserve or drop
    # names, and position-based renaming is incompatible with deduplication
    # regardless (f is called on unique values, so position-based names would be
    # wrong either way). Custom per-element attributes from third-party packages
    # can't be handled generically here — if f produces any, they will reflect
    # only the unique values rather than the full expanded output.
    attrs <- attributes(uf)
    attrs$names <- names(x)
    attributes(out) <- attrs

    out
  }
}
