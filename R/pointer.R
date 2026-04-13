#' Traverse a nested R list using a JSON Pointer string
#'
#' Follows a JSON Pointer (RFC 6901) to retrieve a value from a nested
#' R list. Tilde-escaping (`~0` -> `~`, `~1` -> `/`) is handled per
#' the spec before each token is used for lookup.
#'
#' S7schema converts AJV 0-based array indices to 1-based via
#' `fix_path()` before passing pointers to this function, so integer
#' tokens are used directly as R list positions without adjustment.
#'
#' @param data A named (or unnamed) R list to traverse.
#' @param pointer A JSON Pointer string starting with `/`, e.g.
#'   `"/columns/1/origin"`. Integer tokens address list elements by
#'   1-based position; string tokens address named elements.
#'
#' @return The value at the pointer location, or `NULL` if the pointer
#'   is `NULL`, does not start with `/`, or the path does not exist in
#'   `data`.
#'
#' @examples
#' data <- list(columns = list(list(origin = "Derived")))
#' .read_pointer_value(data, "/columns/1/origin")
#' # [1] "Derived"
#'
#' .read_pointer_value(data, "/columns/99/origin")
#' # NULL
#'
#' @noRd
.read_pointer_value <- function(data, pointer) {
  if (
    is.null(data) ||
      is.null(pointer) ||
      !startsWith(pointer, "/")
  ) {
    return(NULL)
  }
  tokens <- strsplit(
    sub("^/", "", pointer),
    "/",
    fixed = FALSE
  )[[1L]]
  pluck_args <- lapply(tokens, function(token) {
    token <- gsub(
      "~1", "/",
      gsub("~0", "~", token, fixed = TRUE),
      fixed = TRUE
    )
    if (grepl("^[0-9]+$", token)) as.integer(token) else token
  })
  do.call(purrr::pluck, c(list(data), pluck_args, list(.default = NULL)))
}
