#' Read a value from a nested list using a JSON Pointer
#'
#' Traverses a nested R list following a JSON Pointer string.
#' S7schema converts AJV 0-based array indices to 1-based via
#' `fix_path()` before embedding them in error messages, so the
#' pointer strings this function receives use 1-based indices and
#' can be used directly as R list positions. Tilde-escaping
#' (`~0` -> `~`, `~1` -> `/`) is handled per RFC 6901.
#'
#' @param data A named list to traverse.
#' @param pointer A JSON Pointer string with 1-based array indices
#'   (as produced by S7schema error messages),
#'   e.g. `"/columns/1/origin"`.
#'
#' @return The value at the pointer location, or `NULL` if the pointer
#'   is invalid or the path does not exist in `data`.
#'
#' @examples
#' data <- list(columns = list(list(origin = "Derived")))
#' read_pointer_value(data, "/columns/1/origin")
#'
#' @export
read_pointer_value <- function(data, pointer) {
  if (
    is.null(data) ||
    is.null(pointer) ||
    !startsWith(pointer, "/")
  ) {
    return(NULL)
  }
  tokens <- strsplit(
    sub("^/", "", pointer), "/",
    fixed = FALSE
  )[[1L]]
  current <- data
  for (token in tokens) {
    token <- gsub(
      "~1", "/",
      gsub("~0", "~", token, fixed = TRUE),
      fixed = TRUE
    )
    if (!is.list(current)) return(NULL)
    if (grepl("^[0-9]+$", token)) {
      idx <- as.integer(token)
      if (is.na(idx) || idx < 1L || idx > length(current)) {
        return(NULL)
      }
      current <- current[[idx]]
    } else {
      if (!(token %in% names(current))) return(NULL)
      current <- current[[token]]
    }
  }
  current
}
