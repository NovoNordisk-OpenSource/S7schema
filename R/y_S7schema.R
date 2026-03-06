#' @noRd
validate_prop_schema <- function(value) {
  val <- check_file(file = value, ext = "json")
  if (!isTRUE(val)) {
    return(val)
  }
}

#' @noRd
prop_schema <- S7::new_property(
  class = S7::class_character,
  validator = \(value) {
    validate_prop_schema(value)
  }
)

#' @noRd
validate_prop_file <- function(value) {
  val <- check_file(file = value, ext = c("yml", "yaml"))
  if (!isTRUE(val)) {
    return(val)
  }
}

#' @noRd
prop_file <- S7::new_property(
  class = S7::class_character,
  validator = \(value) {
    validate_prop_file(value)
  }
)

#' @noRd
get_prop_validator <- function(self) {
  validator(schema = self@schema)
}

#' @noRd
prop_validator <- S7::new_property(
  class = validator,
  getter = \(self) {
    get_prop_validator(self)
  }
)

#' @noRd
construct_S7schema <- function(file, schema) {
  assert_file(file = file, ext = c("yml", "yaml"))
  validate_yaml(file, schema)
  S7::new_object(
    .parent = yaml::read_yaml(file = file),
    schema = schema,
    file = file
  )
}

#' @noRd
validate_S7schema <- function(self) {
  use_validator(
    validator = self@validator,
    yaml_content = to_yaml(self)
  )
}

#' Work with valid configurations
#' @description
#' `S7schema()` provides a generic way of working with yaml configuration files.
#'
#' The object is created by supplying both an initial YAML configuration (`file`)
#' and the JSON schema definition (`schema`) of the configuration file.
#'
#' The initial configuration is validated before the new object is returned.
#' If not valid the first error is thrown, together with a path to the entry in the YAML file,
#' and a description of the error.
#'
#' The `S7schema` class inherits from `list`, ensuring that the content of the YAML
#' file can be accessed as if read directly with `yaml::read_yaml()`, and supports
#' the below workflow:

#' 1. Read and validate config file: `x <- S7schema(...)`
#' 2. Edit content as if it was a list: `x$new_entry <- "new_value"`
#' 3. Validate new content against the original schema: `validate(x)`
#' 4. Use values in downstream functions: `x$new_entry`
#'
#' @details
#' See internal [validator()] documentation for more info on how the validation is done.
#'
#' @param file `character(1)` path to a yaml file to be checked.
#' @param schema `character(1)` path to a JSON schema.
#' @section Properties:
#' \describe{
#'   \item{schema}{`character(1)` path to JSON schema being used to validate against.}
#'   \item{validator}{Internal [validator()] used to validate the content (read-only).}
#'   \item{file}{`character(1)` path to the source YAML file.}
#' }
#' @returns New `S7schema` object.
#' @examples
#' # Work with yaml configuration file:
#' S7schema(
#'   file = system.file("examples/config.yml", package = "S7schema"),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' )
#'
#' @export
S7schema <- S7::new_class(
  name = "S7schema",
  parent = S7::class_list,
  properties = list(
    schema = prop_schema,
    validator = prop_validator,
    file = prop_file
  ),
  constructor = construct_S7schema,
  validator = \(self) {
    validate_S7schema(self)
  }
)
