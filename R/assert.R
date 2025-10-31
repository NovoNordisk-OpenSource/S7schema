#' @noRd
check_schema <- function(schema) {
  val <- c(
    "Schema must be supplied" = !length(schema),
    "Only one schema is allowed" = length(schema) > 1,
    "File does not exist" = any(!file.exists(schema)),
    "Must be a JSON file" = any(tools::file_ext(schema) != "json")
  )

  errors <- names(val)[which(val)]
  if (length(errors)) {
    return(errors)
  }

  TRUE
}

#' @noRd
assert_schema <- function(schema) {
  val <- check_schema(schema)

  if (isTRUE(val)) {
    return(invisible(schema))
  }

  cli::cli_abort(
    message = c(
      "Illegal schema reference {.file {schema}}",
      rlang::set_names(x = val, nm = "i")
    )
  )
}
