# deduped 0.3.0

* New `with_deduped()` acts on an existing expression: this means you can attach
  deduplication to an existing call, without having to break it up. For example,
  `f(x) |> with_deduped()` instead of `deduped(f)(x)`.
  
* `deduped(f)(x)` now warns rather than errors on anything other than an atomic 
  vector or list and simply acts without deduplication.

# deduped 0.2.0

* `deduped()` now works correctly on list inputs.

## Deprecation

* `deduped_map()` was deprecated since it was found to be slower
and more complex in most cases compared to `deduped(lapply)()` or
`deduped(purrr::map)()`, once the list-input issue (above) was fixed.

# deduped 0.1.4

* Initial successful CRAN submission.

