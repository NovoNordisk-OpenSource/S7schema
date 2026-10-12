#' Convert an R object to YAML
#'
#' @description
#' This function is used internally when validating `list` or `S7schema` objects, and
#' when using `write_config()` to save a configuration.
#'
#' Underneath it is calling `yaml::as.yaml()` to do the conversion, but all `logical` values
#' are converted to `true`/`false` instead of `yes`/`no` respectively for a more robust integration
#' with other YAML parsers.
#' `Date` values are written as ISO 8601 strings (`"2025-08-06"`), and numbers
#' are written with `precision = 15` instead of the default of 7.
#'
#' Missing values are written as:
#' * logical `NA` as `.na`
#' * `NA_character_` as `.na.character`
#' * `NA_integer_` as `.na.integer`
#' * `NA_real_` as `.na.real`
#'
#' R reads all of them back as `NA`, while other YAML parsers read them as
#' strings. Previously logical `NA` was written as `NA`, which R read back as
#' the string `"NA"`.
#'
#' It is rarely relevant to call this function directly except for debugging purposes, or when
#' implementing a new method for your own object class.
#'
#' @details
#' `to_yaml()` dispatches based on the class of `x`. Register a new S7 method if you want to overwrite
#' how your own class is converted to YAML. See `S7::method()` for more information.
#'
#' The default method uses `yaml::verbatim_logical()` to overwrite the default
#' behavior of handling `logical` values, and a handler for `Date` values.
#' The `logical` handler writes `NA` as `.na`, so it is read back as `NA`:
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
#' # Missing logical values are written as .na
#' to_yaml(list(a = NA, b = c(TRUE, NA))) |>
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
    precision = 15,
    handlers = list(
      logical = \(x) {
        x <- yaml::verbatim_logical(x)
        x[is.na(x)] <- ".na"
        x
      },
      Date = \(x) format(x, "%Y-%m-%d")
    )
  )
}

#' Data as R reads it back after writing it with `to_yaml()`
#' @noRd
yaml_round_trip <- function(x) {
  yaml::yaml.load(to_yaml(x))
}
