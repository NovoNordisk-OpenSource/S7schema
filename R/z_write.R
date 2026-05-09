#' Write YAML configuration file
#'
#' Thin wrapper around `to_yaml()` calling `validate()` before
#' converting to YAML and creating the file, ensuring that the saved configuration is valid.
#'
#' @param x `S7schema` object to write.
#' @param path `character(1)` path to the file to write to. Default `NULL` uses `x@file` for `S7schema()` objects.
#' @return Invisible `x` (the input `S7schema` object). Called for side effect
#'   of writing the file.
#' @examples
#' # Read configuration file:
#' x <- S7schema(
#'   file = system.file("examples/config.yml", package = "S7schema"),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' )
#'
#' print(x)
#'
#' # Edit content
#' x$my_config_var <- 2
#'
#' # Save new file
#' write_config(
#'   x = x,
#'   path = tempfile(fileext = ".yml")
#' )
#'
#' @export
write_config <- S7::new_generic(
  name = "write_config",
  dispatch_args = "x",
  fun = \(x, path = NULL) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(write_config, S7schema) <- function(x, path = NULL) {
  write_valid_config(x, path)
}

#' @noRd
write_valid_config <- function(x, path) {
  validate(x)

  if (is.null(path)) {
    path <- x@file
  }

  cat(
    result = to_yaml(x),
    file = path,
    sep = ""
  )

  invisible(x)
}
