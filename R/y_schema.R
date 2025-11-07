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
construct_S7schema <- function(.data, schema) {
  assert_file(file = .data, ext = c("yml", "yaml"))

  S7::new_object(
    .parent = yaml::read_yaml(.data),
    schema = schema
  )
}

#' Schema stuff
#' TODO: Documentaion
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
