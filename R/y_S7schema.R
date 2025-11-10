#' @noRd
prop_schema <- S7::new_property(
  class = S7::class_character,
  validator = \(value) {
    val <- check_file(file = value, ext = "json")
    if (!isTRUE(val)) {
      return(val)
    }
  }
)

#' @noRd
prop_validator <- S7::new_property(
  class = validator,
  getter = \(self) {
    validator(schema = self@schema)
  }
)

#' @noRd
construct_S7schema <- function(file, schema) {
  assert_file(file = file, ext = c("yml", "yaml"))

  S7::new_object(
    .parent = yaml::read_yaml(file = file),
    schema = schema
  )
}

#' Work with valid configurations
#' @description
#' `S7schema` provides a generic way of working with yaml configuration files.
#' sds
#'
#' @details
#' See internal [validator()] documentation for more info on how the validation is done.
#'
#' @param file `character(1)` path to a yaml file to be checked.
#' @param schema `character(1)` path to a JSON schema.
#' @section Properties:
#' \describe{
#'   \item{schema}{`character(1)` path to JSON schema being used to validate against.}
#'   \item{validator}{Internal [validator()] used to validate the content.}
#' }
#' @returns New `S7schema` object.
#' @examplesIf FALSE
#' # Work with yaml configuration file:
#' S7schema(
#'   file = "path/to/my/config.yml",
#'   schema = "path/to/my/schema.json"
#' )
#'
#' @export
S7schema <- S7::new_class(
  name = "S7schema",
  parent = S7::class_list,
  properties = list(
    schema = prop_schema,
    validator = prop_validator
  ),
  constructor = construct_S7schema,
  validator = \(self) {
    use_validator(
      validator = self@validator,
      yaml_content = yaml::as.yaml(self)
    )
  }
)
