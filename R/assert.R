#' @noRd
check_file <- function(file, ext = NULL) {
  if (length(file) != 1L) {
    return(
      cli::format_message("Only exactly {.emph one} file can be referenced")
    )
  }
  if (!file.exists(file)) {
    return(
      cli::format_message("File does not exist")
    )
  }
  if (!is.null(ext) && !tools::file_ext(file) %in% ext) {
    return(
      cli::format_message("Extension must be one of {.emph {ext}}")
    )
  }

  TRUE
}

#' @noRd
assert_file <- function(file, ext = NULL) {
  val <- check_file(file = file, ext = ext)

  if (isTRUE(val)) {
    return(invisible(file))
  }

  cli::cli_abort(
    message = c(
      "Illegal file reference {.file {file}}",
      rlang::set_names(x = val, nm = "i")
    )
  )
}
