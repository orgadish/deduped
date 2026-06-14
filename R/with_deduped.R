#' Deduplicate the first argument in an expression
#'
#' @description
#' This is a convenience wrapper for `deduped()` to allow it to be piped into
#' an expression. It will recursively parse the first arguments of the
#' expression call tree to find the bottom -- when the first argument is not
#' itself a function call.
#'
#' * Without nesting: `f(x, ...) |> with_deduped()` is equivalent to
#'    `deduped(\(.z) f(.z, ...))(x)`.
#' * With nesting: `f(g(x, g2), f2) |> with_deduped()` is equivalent to
#'    `deduped(\(.z) f(g(.z, g2), f2))(x)`.
#'
#'
#' @param expr The expression to evaluate.
#' @param env The environment within which to evaluate the expression. Can be
#'  modified when calling inside other functions.
#'
#' @returns The result of evaluating the expression.
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
#'
#' system.time({
#'   y2 <- with_deduped(slow_func(large_x))
#'
#'   # Can also use the R pipe (R >= 4.1.0) or magrittr pipe, for convenience.
#'   # slow_func(large_x) |> with_deduped()
#' })
#'
#' all(y1 == y2)
with_deduped <- function(expr, env = parent.frame()) {
  call_tree <- substitute(expr)
  if (!is.call(call_tree))
    stop("`expr` must be a function call expression, e.g. `f(x) |> with_deduped()`.")

  # Recursively walks the call tree, replacing the deepest first argument with
  # `.x`. Returns list(node = modified_call, target = original_leaf_expression).
  swap_arg <- function(node) {
    # Base case: node is a literal or symbol (not a call), so this is the
    # deepest first argument — the data to deduplicate. Return it as the target.
    if (!is.call(node))
      return(list(node = quote(.x), target = node))

    # Guard: a call with no first argument (e.g. f()) has nothing to deduplicate.
    if (length(node) < 2)
      stop(sprintf(
        "`%s` has no first argument to deduplicate.",
        deparse(node[[1]])
      ))

    # Recursive case: descend into the first argument and splice the result back.
    result <- swap_arg(node[[2]])
    node[[2]] <- result$node
    list(node = node, target = result$target)
  }

  result <- swap_arg(call_tree)

  f_wrapper <- function(.x) {}
  body(f_wrapper) <- result$node
  # Set environment to the USER'S environment, passed in as 'env'
  environment(f_wrapper) <- env

  # Evaluate the target data in the USER'S environment
  target_data <- eval(result$target, envir = env)

  # Optimization Logic
  deduped(f_wrapper)(target_data)
}
