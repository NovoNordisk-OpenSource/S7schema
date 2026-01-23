#' @noRd
doc_text <- function(txt) {
  if (is.null(txt)) {
    return(NULL)
  }

  as_character_1(txt)
}

#' @noRd
doc_set_header_level <- function(level = NULL, .local_envir = parent.frame()) {
  if (is.null(level)) {
    level <- getOption("doc_header_level") + 1
  }

  withr::local_options(
    .new = list(doc_header_level = level),
    .local_envir = .local_envir
  )
}

#' @noRd
doc_header <- function(txt, level = getOption("doc_header_level")) {
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
  if (!"$ref" %in% names(x)) {
    return(x)
  }

  i <- which(!is.na(x[["$ref"]]))

  ref <- x[["$ref"]][i]

  ref_text <- ref |>
    stringr::str_remove_all("^.*definitions/")

  ref_id <- ref |>
    stringr::str_remove("/") |>
    stringr::str_replace_all("/", "-")

  x[["$ref"]][i] <- paste0("[", ref_text, "](", ref_id, ")")

  x
}

#' @noRd
doc_kable <- function(x) {
  withr::local_options(
    .new = list(knitr.kable.NA = "")
  )

  x |>
    doc_ref_hyperlink() |>
    doc_ref_type() |>
    doc_yesno() |>
    doc_repair_names() |>
    knitr::kable() |>
    as_character_1(collapse = "\n")
}

#' @noRd
as_character_1 <- function(x, collapse = "<br>") {
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
