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
