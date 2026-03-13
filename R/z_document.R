#' Document configuration schema
#' @description
#' Creates markdown documentation of a configuration suitable for
#' use in e.g. vignettes to provide easy readable documentation
#' for users.
#'
#' @param x `character(1)` path to JSON schema, `list()` of already loaded specifications, or `S7schema()` object.
#' @param header_start_level `numeric(1)` Level of initial header.
#' All subheaders will continuously be one level smaller.
#' @return `character(1)`/`knitr::asis_output()` markdown with the documentation.
#' @examplesIf requireNamespace("jsonlite", quietly = TRUE) && requireNamespace("knitr", quietly = TRUE)
#' # Simple example schema
#' system.file("examples/schema.json", package = "S7schema") |>
#'   document_schema(2) |>
#'   cat()
#'
#' # Changing header start level to 1
#' system.file("examples/schema.json", package = "S7schema") |>
#'   document_schema(1) |>
#'   cat()
#'
#' # Example with definitions
#' system.file("examples/definitions.json", package = "S7schema") |>
#'   document_schema(2) |>
#'   cat()
#'
#' @export
document_schema <- S7::new_generic(
  name = "document_schema",
  dispatch_args = "x",
  fun = \(x, header_start_level = 1L) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(document_schema, S7::class_character) <- function(
  x,
  header_start_level = 1L
) {
  document_schema_character(x, header_start_level)
}

#' @noRd
S7::method(document_schema, S7schema) <- function(x, header_start_level = 1L) {
  document_schema(x@schema, header_start_level)
}

#' @noRd
S7::method(document_schema, S7::class_list) <- function(
  x,
  header_start_level = 1L
) {
  document_schema_list(x, header_start_level)
}

#' @noRd
document_schema_character <- function(x, header_start_level) {
  assert_file(file = x, ext = "json")

  rlang::check_installed("jsonlite")

  document_schema(
    x = jsonlite::read_json(x),
    header_start_level = header_start_level
  )
}

#' @noRd
document_schema_list <- function(x, header_start_level) {
  rlang::check_installed("knitr")
  rlang::check_installed("tidyr")
  rlang::check_installed("tibble")
  rlang::check_installed("purrr")
  rlang::check_installed("withr")

  x |>
    doc_ref_hyperlinks() |>
    document_entry(
      title = x$title,
      h_level = header_start_level
    ) |>
    knitr::asis_output()
}

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
    object = document_object(x, h_level),
    oneOf = document_oneOf(x),
    NESTED = document_entries(
      entries = discard_entries(x),
      titles = names(discard_entries(x)),
      h_level = h_level
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
    document_definitions(x = x, h_level = h_level)
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
  x[!names(x) %in% discard]
}

#' @noRd
document_entries <- function(entries, titles, h_level) {
  res <- character(length = length(entries))

  for (i in seq_along(res)) {
    res[[i]] <- document_entry(
      x = entries[[i]],
      titles[[i]],
      h_level = h_level + 1
    )
  }

  as_character_1(x = res, collapse = "\n\n")
}

#' @noRd
document_default <- function(x) {
  x |>
    document_default_helper() |>
    doc_kable()
}

#' @noRd
document_default_helper <- function(x) {
  x |>
    discard_entries() |>
    purrr::map(as_character_1, collapse = "<br>") |>
    unlist() |>
    tibble::enframe(name = "name") |>
    tidyr::pivot_wider()
}

#' @noRd
document_object <- function(x, h_level) {
  c(
    document_default(x),
    document_object_properties(x$properties, x$required, h_level + 1)
  ) |>
    as_character_1(collapse = "\n\n")
}

#' @noRd
document_object_properties <- function(properties, required = NULL, h_level) {
  if (is.null(properties)) {
    return(NULL)
  }

  p <- properties |>
    tibble::enframe(name = "name") |>
    tidyr::unnest_wider(
      col = "value"
    )

  p$required <- p$name %in% required

  c(
    doc_header(txt = "Properties", level = h_level),
    doc_kable(p)
  ) |>
    as_character_1(collapse = "\n\n")
}

#' @noRd
document_definitions <- function(x, h_level) {
  if (is.null(x$definitions)) {
    return(NULL)
  }

  document_entry(
    x = x$definitions,
    title = "Definitions",
    h_level = h_level
  )
}

#' @noRd
document_oneOf <- function(x) {
  x[["oneOf"]] |>
    purrr::map(document_default_helper) |>
    purrr::list_rbind() |>
    doc_kable()
}
