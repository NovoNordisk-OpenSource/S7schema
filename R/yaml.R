#' Convert an R object to YAML
#'
#' @description
#' This function is used internally when validating `list` or `S7schema` objects, and
#' when using `write_config()` to save a configuration.
#'
#' Underneath it is calling `yaml::as.yaml()` to do the conversion, but all `logical` values
#' are converted to `true`/`false` instead of `yes`/`no` respectively for a more robust integration
#' with other YAML parsers.
#'
#' It is rarely relevant to call this function directly except for debugging purposes, or when
#' implementing a new method for your own object class.
#'
#' @details
#' `to_yaml()` dispatches based on the class of `x`. Register a new S7 method if you want to overwrite
#' how your own class is converted to YAML. See `S7::method()` for more information.
#'
#' The default method just uses `yaml::verbatim_logical()` to overwrite the default behavior
#' of handling `logical` values:
#'
#' ```{r, include = FALSE}
#' f <- tempfile()
#' print(as_yaml) |>
#'   capture.output() |>
#'   head(-1) |>
#'   cat(file = f, sep = "\n")
#' ```
#'
#' ```{r, file = f, eval = FALSE}
#' ```
#'
#' Copy this and add your own additional handlers when implementing a new method.
#'
#' @param x object to convert to YAML.
#' @returns `character(1)` YAML string.
#' @examples
#' # Convert simple list to YAML
#' to_yaml(list(hello = "world", is_today = TRUE)) |>
#'   cat()
#'
#' # Convert S7schema object
#' x <- S7schema(
#'   file = system.file("examples/config.yml", package = "S7schema"),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' )
#'
#' print(x)
#'
#' to_yaml(x) |>
#'   cat()
#'
#' @export
to_yaml <- S7::new_generic(
  name = "to_yaml",
  dispatch_args = "x",
  fun = \(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(to_yaml, S7::class_any) <- function(x) {
  as_yaml(x)
}

#' @noRd
as_yaml <- function(x) {
  yaml::as.yaml(
    x = x,
    handlers = list(
      logical = yaml::verbatim_logical
    )
  )
}
