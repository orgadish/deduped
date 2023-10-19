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
