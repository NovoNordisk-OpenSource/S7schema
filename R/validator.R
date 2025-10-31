#' Constructor function for the `schema_validator` class
#'
#' Does the following before:
#' 1. Create a local V8 context to ensure variables etc. are local to the schema
#' 2. Loads the bundled JavaScript file containing ajv, yaml, and helper functions.
#'    See /dev/README.md for how this is created
#' 3. Creates a validator object inside the V8 context for later use
#' 4. Returns the context
#' @noRd
sv_constructor <- function(schema) {
  schema_content <- schema |>
    assert_schema() |>
    readLines() |>
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

#' Schema validator
#' @details
#' Utility validator class containing a V8 context ready to validate input data.
#' @param schema description
#' @export
schema_validator <- S7::new_class(
  name = "schema_validator",
  properties = list(
    context = S7::new_S3_class("V8")
  ),
  constructor = sv_constructor
)

#' @noRd
use_validator <- function(validator, content) {
  yaml_content <- yaml::as.yaml(x = content)

  validator@context$assign(
    name = "yaml_str",
    value = yaml_content
  )

  validator@context$eval(
    src = "var result = validate_yaml(validator, yaml_str);"
  )

  # TODO: Only retireve errors
  # TODO: Can js script be simplified with exports etc.?
  result <- validator@context$get(
    name = "result",
    simplifyVector = FALSE
  )

  if (is.null(result$errors)) {
    return(invisible(content))
  }

  error <- result$errors[[1]]
  cli::cli_abort(
    message = c(
      error$message,
      if (nchar(error$instancePath)) {
        "i" = paste0("Path: ", error$instancePath)
      },
      rlang::set_names(
        x = paste(names(error$params), error$params, sep = ": "),
        nm = "x"
      )
    )
  )
}
