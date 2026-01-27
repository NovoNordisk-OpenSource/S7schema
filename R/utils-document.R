#' @noRd
doc_text <- function(txt) {
  if (is.null(txt)) {
    return(NULL)
  }

  as_character_1(x = txt, collapse = "\n\n")
}

#' @noRd
doc_header <- function(txt, level) {
  txt <- as_character_1(x = txt, collapse = " ")

  rep(x = "#", times = level) |>
    paste(collapse = "") |>
    paste(txt)
}

#' @noRd
doc_repair_names <- function(x) {
  if (is.null(names(x))) {
    return(x)
  }

  nm <- gsub(
    # camelCase => camel Case
    pattern = "(?=[A-Z])",
    replacement = " ",
    x = names(x),
    perl = TRUE
  )
  nm <- gsub(
    # camel Case => Camel Case
    pattern = "\\b([a-zA-Z])(\\w*)\\b",
    replacement = "\\U\\1\\L\\2",
    x = nm,
    perl = TRUE
  )

  names(x) <- nm

  x
}

#' @noRd
doc_yesno <- function(x) {
  if (is.logical(x)) {
    return(doc_yesno_logical(x))
  }

  is_logical <- vapply(X = x, FUN = is.logical, FUN.VALUE = logical(1))

  for (i in which(is_logical)) {
    x[[i]] <- doc_yesno_logical(x[[i]])
  }

  x
}

#' @noRd
doc_yesno_logical <- function(x) {
  c("No", "Yes")[x + 1L]
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
doc_hyperlink <- function(x) {
  if (length(x) > 1 || !is.character(x) || !grepl(pattern = "^#", x = x)) {
    return(x)
  }

  ref_text <- sub(
    pattern = "^.*definitions/",
    replacement = "",
    x = x
  )

  ref_id <- sub(
    pattern = "/.*/",
    replacement = "",
    x = x
  )

  paste0("[", ref_text, "](", ref_id, ")")
}

#' @noRd
doc_ref_hyperlinks <- function(x) {
  purrr::modify_depth(
    .x = x,
    .depth = -1,
    .f = doc_hyperlink,
    .ragged = TRUE
  )
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
    x <- doc_yesno_logical(x)
  }

  x |>
    as.character() |>
    paste(collapse = collapse)
}
