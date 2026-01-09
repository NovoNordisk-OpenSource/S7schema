#' @noRd
doc_text <- function(txt) {
  if (is.null(txt)) {
    return(NULL)
  }

  as_character_1(txt)
}

#' @noRd
doc_header <- function(txt, level = 2) {
  rep(x = "#", times = level) |>
    paste(collapse = "") |>
    paste(txt) |>
    doc_text()
}

#' @noRd
doc_name_repair <- function(x) {
  return(x)
  x |>
    stringr::str_replace_all("^\\$ref$", "reference") |>
    stringr::str_to_title()
}

#' @noRd
doc_kable <- function(x) {
  withr::local_options(.new = list(knitr.kable.NA = ""))

  x |>
    knitr::kable() |>
    as_character_1(collapse = "\n")
}

#' @noRd
as_character_1 <- function(x, collapse = "<br>") {
  x |>
    as.character() |>
    paste(collapse = collapse)
}

#' @noRd
as_character_named <- function(x) {
  x |>
    as.character() |>
    setNames(nm = doc_name_repair(names(x)))
}
