#' Apply a function to each _unique_ element
#'
#' @description
#' Acts like [purrr::map()] but only performs the computation on unique
#' elements.
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
#'
#' @examples
#' slow_func <- function(x) {
#'   for (i in x) {
#'     Sys.sleep(0.001)
#'   }
#' }
#' ux <- purrr::map(1:5, function(j) sample(LETTERS, j, replace = TRUE))
#' x <- sample(rep(ux, 10)) # Create a duplicated vector
#'
#' system.time({
#'   y1 <- purrr::map(x, slow_func)
#' })
#' system.time({
#'   y2 <- deduped_map(x, slow_func)
#' })
#'
#' all.equal(y1, y2)
deduped_map <- function(.x, .f, ..., .progress = FALSE) {
  check_map_pkgs()

  # purrr::map can map over a vector, but a list is needed here.
  .x <- as.list(.x)

  # Use `hashr::hash(x, recursive=FALSE)` directly once markvanderloo/hashr#3
  # is resolved.
  nonrecursive_hash <- function(x) {
    if (inherits(x, c("list", "character"))) {
      hashr::hash(x, recursive = FALSE)
    } else {
      hashr::hash(x)
    }
  }

  hashes <- purrr::map_int(.x, nonrecursive_hash)
  unq_hashes <- collapse::funique(hashes)
  unq_x <- purrr::map(unq_hashes, \(h) .x[[collapse::whichv(hashes, h)[1]]])

  redup_indices <- fastmatch::fmatch(hashes, unq_hashes)
  purrr::map(unq_x, .f, ..., .progress = .progress)[redup_indices]
}


check_map_pkgs <- function() {
  not_installed <- c(
    if (!requireNamespace("hashr", quietly = TRUE)) "hashr",
    if (!requireNamespace("purrr", quietly = TRUE)) "purrr"
  )

  if (length(not_installed) == 0) {
    return(invisible())
  }

  not_installed_txt <- paste(paste0("\"", not_installed, "\""), collapse = ", ")

  stop(paste0(
    "The following packages are missing and ",
    "must be installed to use `deduped_map()`: ",
    not_installed_txt,
    "\nUse `install.packages(c(", not_installed_txt, "))` to install them."
  ))
}
