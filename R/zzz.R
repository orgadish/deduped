.onLoad <- function(libname, pkgname) {
  # Only set if not already defined, so user .Rprofile settings are respected.
  if (is.null(getOption("deduped.verbose")))
    options(deduped.verbose = FALSE)
}
