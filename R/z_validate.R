#' Validate
#' @export
validate_schema <- S7::new_generic(
  name = "validate_schema",
  dispatch_args = "x"
)

#' @export
S7::method(validate_schema, schema_validator) <- function(
  x,
  content
) {
  use_validator(validator = x, content = content)
}
