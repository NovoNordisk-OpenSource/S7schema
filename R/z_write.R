#' Write YAML configuration file
#'
#' Thin wrapper around `to_yaml()` calling `validate()` before
#' converting to YAML and creating the file, ensuring that the saved configuration is valid.
#'
#' @param x `S7schema` object to write.
#' @param file `character(1)` path to the file to write to. Defaults to `x@file` if not provided.
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
#'   file = tempfile(fileext = ".yml")
#' )
#'
#' @export
write_config <- S7::new_generic(
  name = "write_config",
  dispatch_args = "x",
  fun = \(x, file = x@file) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(write_config, S7schema) <- function(x, file = x@file) {
  write_valid_config(x, file)
}

#' @noRd
write_valid_config <- function(x, file) {
  validate(x)

  cat(
    result = to_yaml(x),
    file = file,
    sep = ""
  )

  invisible(x)
}
