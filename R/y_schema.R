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
construct_S7schema <- function(.data, schema) {
  assert_file(file = .data, ext = c("yml", "yaml"))

  S7::new_object(
    .parent = yaml::read_yaml(.data),
    schema = schema,
    validator = validator(schema = schema)
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
    validator = validator # TODO: Update with schema!
  ),
  constructor = construct_S7schema,
  validator = \(self) {
    validate(self)
    NULL
  }
)
