#' Validate configuration
#' @description
#' Check if a configuration is in accordance with a JSON schema definition.
#'
#' It is possible to both validate an existing object in memory and an existing configuration file.
#'
#' @param x Object to validate. Either `list` or a `character` path to file.
#' @param schema Path to JSON schema definition
#' @return `invisible(x)`
#' @examples
#' # See all registered methods
#' validate
#'
#' @examplesIf FALSE
#' # Validate list object in memory
#' validate(
#'   x = list(a = 1),
#'   schema = "path/to/my/schema.json"
#' )
#'
#' # Validate yaml file on disk
#' validate(
#'   x = "path/to/my/config.yml",
#'   schema = "path/to/my/schema.json"
#' )
#' @export
validate <- S7::new_generic(
  name = "validate",
  dispatch_args = "x",
  fun = \(x, schema) {
    S7::S7_dispatch()
  }
)

#' @noRd
validate_list <- function(x, schema) {
  use_validator(
    validator = validator(schema = schema),
    yaml_content = yaml::as.yaml(x)
  )

  invisible(x)
}

S7::method(validate, S7::class_list) <- function(x, schema) {
  validate_list(x = x, schema = schema)
}

#' @noRd
validate_yaml <- function(x, schema) {
  content <- x |>
    assert_file(ext = c("yml", "yaml")) |>
    readLines(warn = FALSE) |>
    paste(collapse = "\n")

  use_validator(
    validator = validator(schema = schema),
    yaml_content = content
  )

  invisible(x)
}

S7::method(validate, S7::class_character) <- function(x, schema) {
  validate_yaml(x = x, schema = schema)
}
