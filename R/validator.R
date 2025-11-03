#' Constructor function for the internal `validator` class
#'
#' Does the following before:
#' 1. Create a local V8 context to ensure variables etc. are local to the schema
#' 2. Loads the bundled JavaScript file containing ajv, yaml, and helper functions.
#'    See /dev/README.md for how this is created
#' 3. Creates a validator object inside the V8 context for later use
#' 4. Returns the context
#' @noRd
construct_validator <- function(schema) {
  schema_content <- schema |>
    assert_file(ext = "json") |>
    readLines(warn = FALSE) |>
    paste(collapse = "\n")

  ctx <- V8::v8()

  ctx$source(system.file("bundle.js", package = "S7schema"))

  ctx$assign("schema_str", schema_content)
  ctx$eval("var validator = create_validator(schema_str);")

  S7::new_object(
    .parent = S7::S7_object(),
    context = ctx
  )
}

#' @noRd
validator <- S7::new_class(
  name = "validator",
  properties = list(
    context = S7::new_S3_class("V8")
  ),
  constructor = construct_validator
)

#' @noRd
use_validator <- function(validator, yaml_content) {
  validator@context$assign(
    name = "yaml_str",
    value = yaml_content
  )

  validator@context$eval(
    src = "var result = validate_yaml(validator, yaml_str);"
  )

  # TODO: Only retrieve errors
  # TODO: Can js script be simplified with exports etc.?
  result <- validator@context$get(
    name = "result",
    simplifyVector = FALSE
  )

  if (is.null(result$errors)) {
    return(invisible())
  }

  error <- result$errors[[1]]
  cli::cli_abort(
    message = c(
      "{.file {error$instancePath}} {error$message}",
      rlang::set_names(
        x = paste(names(error$params), error$params, sep = ": "),
        nm = "x"
      )
    )
  )
}
