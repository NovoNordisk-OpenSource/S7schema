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
  ctx$eval("var validator = createValidator(schema_str);")

  S7::new_object(
    .parent = S7::S7_object(),
    context = ctx
  )
}

#' Internal validator based on a JSON schema
#' @description
#' Based on a JSON schema, [ajv](https://ajv.js.org) is used to create a validator
#' object in Javascript that can be used to check an input yaml.
#' This is done in a [V8::v8()] context, and stored inside
#' the `context` property of the the object.
#'
#' See [json-schema.org](https://json-schema.org) on how to specify a JSON schema.
#'
#' @inheritParams S7schema
#' @returns New `validator` object
#' @section Properties:
#' \describe{
#'   \item{context}{[V8::v8()] context with a validator object based on the schema}
#' }
#' @keywords internal
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
    src = "var result = validateYaml(validator, yaml_str);"
  )

  result <- validator@context$get(
    name = "result",
    simplifyVector = FALSE
  )

  if (is.null(result$errors)) {
    return(invisible())
  }

  cli::cli_abort(message = format_errors(result$errors))
}

#' @noRd
format_errors <- function(errors) {
  is_oneof <- vapply(
    X = errors,
    FUN = \(e) identical(e$keyword, "oneOf"),
    FUN.VALUE = logical(1)
  )

  if (!any(is_oneof)) {
    error <- errors[[1]]
    header <- cli::format_inline(
      "{.field {error$instancePath}} {error$message}"
    )
    return(c(
      header,
      rlang::set_names(
        x = paste(names(error$params), error$params, sep = ": "),
        nm = "x"
      )
    ))
  }

  oneof_error <- errors[is_oneof][[1]]

  is_sub <- vapply(
    X = errors,
    FUN = \(e) grepl("/oneOf/", e$schemaPath, fixed = TRUE),
    FUN.VALUE = logical(1)
  )

  header <- cli::format_inline(
    "{.field {oneof_error$instancePath}} {oneof_error$message}"
  )

  bullets <- vapply(errors[is_sub], \(e) e$message, character(1))
  c(header, rlang::set_names(bullets, rep("*", length(bullets))))
}
