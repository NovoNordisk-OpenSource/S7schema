#' One-shot validation of configurations
#' @description
#' Check if a configuration is in accordance with a JSON schema definition.
#'
#' It is possible to either validate an existing `list` object in memory or an existing
#' `yaml` configuration file.
#'
#' @inherit S7schema details
#' @param x `list` object to validate
#' @inheritParams S7schema
#' @examples
#' # Validate list object in memory
#' validate_list(
#'   x = list(my_config_var = 1),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' ) |>
#'   print()
#'
#' # Validate yaml file on disk
#' validate_yaml(
#'   file = system.file("examples/config.yml", package = "S7schema"),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' ) |>
#'   print()
#'
#' @seealso [S7schema()]
#' @name validate_config
NULL

#' @rdname validate_config
#' @return * `validate_list()`: `invisible(x)`
#' @export
validate_list <- function(x, schema) {
  UseMethod("validate_list")
}

#' @export
validate_list.list <- function(x, schema) {
  use_validator(
    validator = validator(schema = schema),
    yaml_content = to_yaml(x)
  )

  invisible(x)
}

#' @rdname validate_config
#' @return * `validate_yaml()`: `invisible(file)`
#' @export
validate_yaml <- function(file, schema) {
  UseMethod("validate_yaml")
}

#' @export
validate_yaml.character <- function(file, schema) {
  content <- file |>
    assert_file(ext = c("yml", "yaml")) |>
    readLines(warn = FALSE) |>
    paste(collapse = "\n")

  use_validator(
    validator = validator(schema = schema),
    yaml_content = content,
    file = file
  )

  invisible(file)
}
