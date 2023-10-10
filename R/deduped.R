#' Deduplicate a function on its first argument
#'
#' @param f Function to deduplicate.
#'
#' @return Deduplicated function
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
#' long_func <- function(x) for(i in x) {Sys.sleep(0.001)}
#'
#' system.time({y1 <- long_func(large_x)})
#' system.time({y2 <- deduped(long_func)(large_x)})
#'
#' all(y1 == y2)
deduped <- function(f) {
  function(x, ...) {
    ux <- collapse::funique(x)
    f(ux, ...)[fastmatch::fmatch(x, ux)]
  }
}
