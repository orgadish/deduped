# Resubmission: deduped 0.5.0

## New Features
* `deduped()` and `with_deduped()` gain a new `verbose` argument which adds
 informative deduplication messaging if TRUE, either by passing the argument or
 setting the new global `options(deduped.verbose = TRUE)`.
* `deduped()` now has early exits for inputs of length <= 1 or when no 
 duplication is found.
 
## Bug Fixes
* `deduped()` now drops names if `f()` drops names, but keeps input names
 otherwise. Previously it always kept input names (#5).

## Deletion of deduped_map()
* `deduped_map()` has now been completely deleted and the "Suggests" dependence 
 on purr has been removed. The function was deprecated with a warning in 
 0.2.0 and has no documented usage on github or cran.
 
## Minor updates
* Added checks in `with_deduped()` for malformed inputs (e.g. not a call tree,
 or a call with no first argument to deduplicate.)
* Added more comprehensive tests for existing and new behavior.


## R CMD check results

── R CMD check results ────────────────────────────────────────────────────── deduped 0.5.0 ────
Duration: 31.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# Resubmission: deduped 0.4.0
Updated helpers to properly maintain and handle attributes, including named vectors.
Removed dependency on `fastmatch::fmatch` and replaced with `collapse::fmatch` which
doesn't mutate the input as a side-effect. Added an error when a function changes the
length.

## R CMD check results

── R CMD check results ────────────────────────────────────────────────── deduped 0.4.0 ────
Duration: 59.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# Resubmission: deduped 0.3.0
Added new `with_deduped()` and allowed `deduped()` to pass incompatible inputs
through as-is with a warning rather than an error.

## R CMD check results

── R CMD check results ────────────────────────────────────────────────── deduped 0.3.0 ────
Duration: 39.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


# Resubmission: deduped 0.2.0
Fixed bug in `deduped()` and deprecated `deduped_map()`.

## R CMD check results

── R CMD check results ─────────────────────────────────────── deduped 0.2.0 ────
Duration: 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


# Resubmission: deduped 0.1.4
Addressed reviewer comments from 2023-10-20
- Added \value to deduped_map.Rd.

Other minor updates
- Set `Roxygen: list(markdown = TRUE)`
- Updated wording in documentation.

## R CMD check results

── R CMD check results ─────────────────────────────────── deduped 0.1.4 ────
Duration: 13.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# Resubmission: deduped 0.1.3
Addressed reviewer comments from 2023-10-19
- Use Authors@R instead of Author, Maintainer

- Remove backquotes in DESCRIPTION: use "deduped()" instead of "`deduped()`"

New additions since previous submission:
- Added `deduped_map()` function.

## R CMD check results

── R CMD check results ──────────────── deduped 0.1.3 ────
Duration: 13.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# Prior submissions

## Resubmission: deduped 0.1.2
- Added `()` to DESCRIPTION and
  README where a function name was referenced

- Changed test to use `withr::with_envvar` instead of
  setting a global variable with `<<-` which is not
  allowed.

- Reviewer asked about adding references
  for the methods. However, the methods are simple and
  do not have any references.
  
## Resubmission: deduped 0.1.1
- Reduced example duration by 10x

- Added words caught by spell check into inst/WORDLIST file

- Reworded DESCRIPTION for clarity

## Original submission: deduped 0.1.0
