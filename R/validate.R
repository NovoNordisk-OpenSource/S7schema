#' Validate configuration
#' @description
#' Check if a configuration is in accordance with a JSON schema definition.
#'
#' It is possible to either validate an existing `list` object in memory or an existing
#' `yaml` configuration file.
#'
#' @param x `list` object to validate
#' @param file `character(1)` path to a yaml file to be checked
#' @param schema `character(1)` path to a JSON schema
#' @examplesIf FALSE
#' # Validate list object in memory
#' validate_list(
#'   x = list(a = 1),
#'   schema = "path/to/my/schema.json"
#' )
#'
#' # Validate yaml file on disk
#' validate_yaml(
#'   file = "path/to/my/config.yml",
#'   schema = "path/to/my/schema.json"
#' )
#' @name validate_config
NULL

#' @rdname validate_config
#' @return * `validate_list()`: `invisible(x)`
validate_list <- function(x, schema) {
  UseMethod("validate_list")
}

#' @export
validate_list.list <- function(x, schema) {
  use_validator(
    validator = validator(schema = schema),
    yaml_content = yaml::as.yaml(x)
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
    yaml_content = content
  )

  invisible(file)
}
