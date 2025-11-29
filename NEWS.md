# deduped 0.3.0

* Added `with_deduped()` to allow piping an existing expression without having
  to break it up.
* When a non-atomic vector `x` is passed into `deduped(f)(x)`, it now warns,
  but simply performs `f(x)`, rather than error.

# deduped 0.2.0

* Updated `deduped()` to work correctly on list inputs.

## Deprecation

* `deduped_map()` was deprecated since it was found to be slower
and more complex in most cases compared to `deduped(lapply)()` or
`deduped(purrr::map)()`, once the list-input issue (above) was fixed.

# deduped 0.1.4

* Initial successful CRAN submission.

