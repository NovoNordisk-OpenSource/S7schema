# x <- jsonlite::read_json("../mighty.metadata/inst/schema/adam.json")

#' Document schema
#' @export
document_schema <- S7::new_generic(
  name = "document_schema",
  dispatch_args = "x",
  fun = \(x, header_start_level) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(document_schema, S7::class_character) <- function(
  x,
  header_start_level
) {
  document_schema_character(x, header_start_level)
}

#' @noRd
S7::method(document_schema, S7schema) <- function(x, header_start_level) {
  document_schema(x@schema, header_start_level)
}

#' @noRd
S7::method(document_schema, S7::class_list) <- function(x, header_start_level) {
  document_schema_list(x, header_start_level)
}

#' @noRd
document_schema_character <- function(x, header_start_level) {
  assert_file(file = x, ext = "json")

  x |>
    jsonlite::read_json() |>
    document_schema(x, header_start_level)
}

#' @noRd
document_schema_list <- function(x, header_start_level) {
  rlang::check_installed("knitr")

  doc_set_header_level(level = header_start_level)

  document_entry(
    x = x,
    title = x$title
  ) |>
    knitr::asis_output()
}

# c(
#   doc_header(txt = x$title, level = 2),
#   x$description,
#   document_default(x),
#   doc_header("Properties", level = header_start_level + 1)
# ) |>
#   as_character_1(collapse = "\n\n") |>
#   knitr::asis_output()

# #' @noRd
# document_schema_list <- function(x, header_level = 2) {
#   rlang::check_installed("knitr")

#   c(
#     document_entry(x, x$title),
#     document_entry(x$definitions, "Definitions")
#   ) |>
#     as_character_1(collapse = "\n\n") |>
#     knitr::asis_output()
# }

#' @noRd
document_entry <- function(x, title, h_level) {
  entry_type <- x$type

  if ("oneOf" %in% names(x)) {
    entry_type <- "oneOf"
  } else if (is.null(entry_type)) {
    entry_type <- "NESTED"
  }

  txt <- switch(
    EXPR = entry_type,
    object = document_object(x),
    oneOf = document_oneOf(x),
    NESTED = document_entries(
      entries = discard_entries(x),
      titles = names(discard_entries(x))
    ),
    document_default(x)
  )

  c(
    doc_header(
      txt = title,
      level = h_level
    ),
    doc_text(txt = x$description),
    txt,
    document_definitions(x = x)
  ) |>
    as_character_1(collapse = "\n\n")
}

#' @noRd
discard_entries <- function(
  x,
  discard = c(
    "$schema",
    "$id",
    "title",
    "description",
    "properties",
    "definitions"
  )
) {
  i <- which(names(x) %in% discard)
  x[i] <- NULL
  x
}

#' @noRd
document_entries <- function(entries, titles) {
  res <- character(length = length(entries))

  for (i in seq_along(res)) {
    res[[i]] <- document_entry(
      x = entries[[i]],
      titles[[i]]
    )
  }

  as_character_1(res, collapse = "\n\n")
}

#' @noRd
document_default <- function(x) {
  x |>
    discard_entries() |>
    purrr::map(as_character_1) |>
    unlist() |>
    tibble::enframe(name = "name") |>
    tidyr::pivot_wider() |>
    doc_kable()
}

#' @noRd
document_object <- function(x) {
  c(
    document_default(x),
    document_object_properties(x$properties, x$required)
  ) |>
    as_character_1(collapse = "\n\n")
}

#' @noRd
document_object_properties <- function(properties, required = NULL) {
  if (is.null(properties)) {
    return(NULL)
  }

  p <- properties |>
    tibble::enframe(name = "name") |>
    tidyr::unnest_wider(
      col = value
    ) |>
    dplyr::mutate(
      requried = name %in% required
    )

  c(
    "**Properties:**",
    "",
    doc_kable(p)
  )
}

#' @noRd
document_definitions <- function(x) {
  if (is.null(x$definitions)) {
    return(NULL)
  }

  document_entry(
    x = x$definitions,
    title = "Definitions"
  )
}

#' @noRd
document_oneOf <- function(x) {
  x[["oneOf"]] |>
    purrr::map(
      .f = \(x) {
        x |>
          discard_entries() |>
          purrr::map(as_character_1) |>
          unlist() |>
          tibble::enframe(name = "name") |>
          tidyr::pivot_wider()
      }
    ) |>
    dplyr::bind_rows() |>
    doc_kable()
}
