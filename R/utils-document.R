#' @noRd
doc_text <- function(txt) {
  if (is.null(txt)) {
    return(NULL)
  }

  as_character_1(x = txt, collapse = "\n\n")
}

#' @noRd
doc_header <- function(txt, level) {
  rep(x = "#", times = level) |>
    paste(collapse = "") |>
    paste(txt) |>
    doc_text()
}

#' @noRd
doc_repair_names <- function(x) {
  if (is.null(names(x))) {
    return(x)
  }

  names(x) <- names(x) |>
    stringr::str_replace_all("(?=[A-Z])", " ") |>
    stringr::str_to_title()

  x
}

#' @noRd
doc_yesno <- function(x) {
  is_logical <- vapply(X = x, FUN = is.logical, FUN.VALUE = logical(1))

  for (i in which(is_logical)) {
    j <- which(x[[i]])
    x[[i]][-j] <- "No"
    x[[i]][j] <- "Yes"
  }

  x
}

#' @noRd
doc_ref_type <- function(x) {
  if (!"$ref" %in% names(x)) {
    return(x)
  }

  i <- !is.na(x[["$ref"]])
  x[["type"]][i] <- x[["$ref"]][i]
  x[["$ref"]] <- NULL

  x
}

#' @noRd
doc_ref_hyperlink <- function(x) {
  if (length(x) > 1 || !is.character(x) || !stringr::str_detect(x, "^#")) {
    return(x)
  }

  ref_text <- x |>
    stringr::str_remove_all("^.*definitions/")

  ref_id <- x |>
    stringr::str_remove("/.*/")

  paste0("[", ref_text, "](", ref_id, ")")
}

#' @noRd
doc_kable <- function(x) {
  withr::local_options(
    .new = list(knitr.kable.NA = "")
  )

  x |>
    doc_ref_type() |>
    doc_yesno() |>
    doc_repair_names() |>
    knitr::kable() |>
    as_character_1(collapse = "\n")
}

#' @noRd
as_character_1 <- function(x, collapse) {
  if (is.logical(x)) {
    i <- which(x)
    x[] <- "No"
    x[i] <- "Yes"
  }

  x |>
    as.character() |>
    paste(collapse = collapse)
}

#' @noRd
as_character_named <- function(x) {
  x |>
    as.character() |>
    setNames(nm = names(x))
}
