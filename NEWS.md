# deduped 0.4.0
* `deduped(f)(x)` (and `with_deduped`) check that the function maintains length
  and error if not.
  
* `deduped(f)(x)` (and `with_deduped`) now maintain names and attributes (since 
  we check that length is preserved). This includes functions that add attributes
  like `fs::path()` where previously this dropped those. Added `fs::path_rel`
  example to README.
  
* Changed to using `collapse::fmatch` and `base::match` in place of `fastmatch::fmatch` 
  which as a side effect adds a hash attribute. Removed dependency on `fastmatch`.


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

