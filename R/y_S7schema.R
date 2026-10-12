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
#' The content is validated as R reads it: files are read with
#' `yaml::read_yaml()`, and `list` or `S7schema` objects are converted with
#' `to_yaml()` and read back before validation.
#' See internal [validator()] documentation for more info on how the validation is done.
#'
#' R reads a YAML sequence with one item (`[a]`) as a single value (`"a"`).
#' For fields that can hold one or more values, allow both forms in the schema
#' with `oneOf`:
#'
#' ```json
#' {
#'   "oneOf": [
#'     {"type": "string"},
#'     {"type": "array", "items": {"type": "string"}}
#'   ]
#' }
#' ```
#'
#' @param file `character(1)` path to a yaml file to be checked. Or `NULL` if created using `.data`.
#' @param schema `character(1)` path to a JSON schema.
#' @param .data `list()` input to create the object. Mutually exclusive with `file`.
#' @section Properties:
#' \describe{
#'   \item{schema}{`character(1)` path to JSON schema being used to validate against.}
#'   \item{validator}{Internal [validator()] used to validate the content (read-only).}
#'   \item{file}{`character(1)` path to the source YAML file (or `NULL` if not set).}
#' }
#' @returns New `S7schema` object.
#' @examples
#' # Work with yaml configuration file:
#' S7schema(
#'   file = system.file("examples/config.yml", package = "S7schema"),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' )
#'
#' # Create object in memory
#' S7schema(
#'   .data = list(my_config_var = 6),
#'   schema = system.file("examples/schema.json", package = "S7schema")
#' )
#' @name S7schema
NULL

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
  if (is.null(value)) {
    return()
  }

  val <- check_file(file = value, ext = c("yml", "yaml"))
  if (!isTRUE(val)) {
    return(val)
  }
}

#' @noRd
prop_file <- S7::new_property(
  class = NULL | S7::class_character,
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
construct_S7schema <- function(file, schema, .data) {
  rlang::check_exclusive(file, .data)

  if (!rlang::is_missing(.data)) {
    return(
      S7::new_object(
        .parent = .data,
        schema = schema,
        file = NULL
      )
    )
  }

  content <- file |>
    assert_file(ext = c("yml", "yaml")) |>
    yaml::read_yaml()

  use_validator(
    validator = validator(schema = schema),
    data = content,
    file = file
  )

  S7::new_object(
    .parent = content,
    schema = schema,
    file = file
  )
}

#' @noRd
validate_S7schema <- function(self) {
  use_validator(
    validator = self@validator,
    data = yaml_round_trip(self)
  )
}

#' @rdname S7schema
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
