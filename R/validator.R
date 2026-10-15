#' Constructor function for the internal `validator` class
#'
#' Does the following before:
#' 1. Create a local QuickJS context to ensure variables etc. are local to the
#'    schema
#' 2. Loads the bundled JavaScript file containing ajv and helper functions.
#'    See /dev/README.md for how this is created
#' 3. Compiles and stores a validator inside the QuickJS context for later use.
#'    Aborts if the schema is not valid JSON or not a valid JSON schema
#' 4. Returns the context
#' @noRd
construct_validator <- function(schema, call = rlang::caller_env()) {
  schema_content <- schema |>
    assert_file(ext = "json") |>
    readLines(warn = FALSE) |>
    paste(collapse = "\n")

  # ajv needs more than the 256 KB default stack of QuickJSR < 1.5.0
  ctx <- QuickJSR::JSContext$new(stack_size = 1024L * 1024L)
  ctx$source(file = system.file("bundle.js", package = "S7schema"))
  # createValidator() returns the error message if the schema is invalid
  msg <- ctx$call("createValidator", schema_content)
  if (!is.null(msg)) {
    cli::cli_abort(
      message = c("Invalid JSON schema {.file {schema}}", x = "{msg}"),
      call = call
    )
  }

  S7::new_object(
    .parent = S7::S7_object(),
    context = ctx
  )
}

#' Internal validator based on a JSON schema
#' @description
#' Based on a JSON schema, [ajv](https://ajv.js.org) is used to create a validator
#' object in Javascript that can be used to check a configuration.
#' This is done in a QuickJS context ([QuickJSR::JSContext]), and stored inside
#' the `context` property of the the object.
#'
#' All YAML is parsed in R, so the validated data is what R reads:
#' * Files are read with `yaml::read_yaml()`.
#' * `S7schema` objects are converted with `to_yaml()` and read back with
#'   `yaml::yaml.load()`, so the validated data matches what `write_config()`
#'   writes.
#' * `list` objects in `validate_list()` are validated as they are.
#'
#' The resulting `list` is converted to JSON with `jsonlite::toJSON()` and
#' validated by ajv. The JavaScript side never parses YAML.
#' `NA`, `NaN`, and `Inf` values become `null` in the JSON sent to ajv.
#' Numbers are sent with 17 significant digits, so numbers from files and
#' lists are validated exactly. `S7schema` objects are validated as
#' `write_config()` writes them, so numbers that need 17 significant digits
#' (e.g. `0.1 + 0.2`) are rounded.
#'
#' See [json-schema.org](https://json-schema.org) on how to specify a JSON schema.
#'
#' @inheritParams S7schema
#' @param call The execution environment shown in error messages if the
#'   schema is invalid. See [rlang::abort()].
#' @returns New `validator` object
#' @section Properties:
#' \describe{
#'   \item{context}{[QuickJSR::JSContext] with a validator object based on
#'     the schema}
#' }
#' @keywords internal
validator <- S7::new_class(
  name = "validator",
  properties = list(
    context = S7::new_S3_class("JSContext")
  ),
  constructor = construct_validator
)

#' @noRd
fix_path <- function(path) {
  if (nchar(path) == 0L) {
    return("(root)")
  }
  m <- gregexpr(
    pattern = "(?<=/)\\d+(?=/|$)",
    text = path,
    perl = TRUE
  )
  regmatches(x = path, m = m) <- lapply(
    X = regmatches(x = path, m = m),
    FUN = \(x) as.integer(x) + 1L
  )
  path
}

#' @noRd
use_validator <- function(
  validator,
  data,
  file = NULL,
  call = parent.frame()
) {
  # validateJson() returns a JSON string: QuickJSR simplifies arrays to
  # vectors when converting to R
  result <- validator@context$call("validateJson", to_json(data)) |>
    jsonlite::fromJSON(simplifyVector = FALSE)

  if (is.null(result$errors)) {
    return(invisible())
  }

  msg <- format_errors(result$errors)

  if (!is.null(file)) {
    msg <- c(
      "Validation failed for {.file {file}}",
      msg
    )
  }

  cli::cli_abort(message = msg, call = call)
}

#' Convert data to a JSON string. `NULL` and `NA` become `null`,
#' and numbers keep 17 significant digits.
#' @noRd
to_json <- function(x) {
  jsonlite::toJSON(
    x = x,
    auto_unbox = TRUE,
    null = "null",
    na = "null",
    digits = I(17)
  ) |>
    as.character()
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
      "{.field {fix_path(error$instancePath)}} {error$message}"
    )
    bullets <- paste(names(error$params), error$params, sep = ": ")

    return(
      c(
        header,
        rlang::set_names(x = bullets, nm = rep("x", length(bullets))),
        format_value(error$data)
      )
    )
  }

  oneof_error <- errors[is_oneof][[1]]

  is_sub <- vapply(
    X = errors,
    FUN = \(e) {
      !identical(e$keyword, "oneOf") &&
        startsWith(e$instancePath, oneof_error$instancePath)
    },
    FUN.VALUE = logical(1)
  )

  header <- cli::format_inline(
    "{.field {fix_path(oneof_error$instancePath)}} {oneof_error$message}"
  )

  bullets <- vapply(
    X = errors[is_sub],
    FUN = \(e) e$message,
    FUN.VALUE = character(1)
  )

  c(
    header,
    rlang::set_names(x = bullets, nm = rep("*", length(bullets))),
    format_value(oneof_error$data)
  )
}

#' @noRd
format_value <- function(value) {
  if (!rlang::is_scalar_atomic(value)) {
    return(NULL)
  }

  rlang::set_names(
    x = cli::format_inline("current value: {.val {value}}"),
    nm = "i"
  )
}
