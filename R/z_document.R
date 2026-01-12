# x <- jsonlite::read_json("../mighty.metadata/inst/schema/adam.json")

#' Document schema
#' @export
document_schema <- S7::new_generic(
  name = "document_schema",
  dispatch_args = "x",
  fun = \(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(document_schema, S7::class_list) <- function(x) {
  document_schema_list(x)
}

#' @noRd
S7::method(document_schema, S7::class_character) <- function(x) {
  assert_file(file = x, ext = "json")

  x |>
    jsonlite::read_json() |>
    document_schema(x)
}

#' @noRd
S7::method(document_schema, S7schema) <- function(x) {
  document_schema(x@schema)
}

#' @noRd
document_schema_list <- function(x, header_level = 2) {
  rlang::check_installed("knitr")

  c(
    document_entry(x, x$title),
    document_entry(x$definitions, "Definitions")
  ) |>
    as_character_1(collapse = "\n\n") |>
    knitr::asis_output()
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
document_entry <- function(x, title) {
  entry_type <- x$type
  if ("oneOf" %in% names(x)) {
    entry_type <- "oneOf"
  }

  if (is.null(entry_type)) {
    return(
      x |>
        discard_entries() |>
        document_entries(names(x))
    )
  }

  txt <- switch(
    EXPR = entry_type,
    object = document_object(x),
    oneOf = document_oneOf(x),
    document_default(x)
  )

  c(
    doc_header(title),
    doc_text(x$description),
    txt
  ) |>
    as_character_1(collapse = "\n\n")
}

#' @noRd
document_default <- function(x) {
  x |>
    discard_entries() |>
    purrr::map(as_character_1) |>
    as_character_named() |>
    tibble::enframe(name = "name") |>
    tidyr::pivot_wider() |>
    doc_kable()
}

#' @noRd
document_object <- function(x) {
  c(
    document_default(x),
    "",
    document_object_properties(x$properties, x$required)
  ) |>
    as_character_1(collapse = "\n")
}

#' @noRd
document_object_properties <- function(properties, required = NULL) {
  if (is.null(properties)) {
    return(NULL)
  }

  properties |>
    tibble::enframe(name = "name") |>
    tidyr::unnest_wider(
      col = value,
      names_repair = doc_name_repair
    ) |>
    dplyr::mutate(
      requried = name %in% required
    ) |>
    doc_kable()
}

#' @noRd
document_oneOf <- function(x) {
  x[["oneOf"]] |>
    purrr::map(
      .f = \(x) {
        x |>
          discard_entries() |>
          purrr::map(as_character_1) |>
          as_character_named() |>
          tibble::enframe(name = "name") |>
          tidyr::pivot_wider()
      }
    ) |>
    dplyr::bind_rows() |>
    doc_kable()
}

# document_entry <- function(x) {
#   x |>
# purrr::map(as_character_1) |>
#   as_character_named() |>
#   tibble::enframe(name = "name") |>
#   tidyr::pivot_wider()
# }

# document_properties <- function(x) {
#
#   properties <- x[["properties"]] |>
#     tibble::enframe(name = "name") |>
#     tidyr::unnest_wider(
#       col = value,
#       names_repair = doc_name_repair
#     )

#   required <- unlist(x[["required"]])
#   if (!is.null(required)) {
#     properties$Required <- character(length = nrow(properties))
#     properties$Required[properties$Name %in% required] <- "Yes"
#   }

#   if ("Reference" %in% names(properties)) {
#     i <- which(!is.na(properties[["Reference"]]))
#     ref <- properties[["Reference"]][i]
#     ref_text <- stringr::str_remove_all(ref, "^.*definitions/")
#     ref_id <- stringr::str_remove(ref, "/") |>
#       stringr::str_replace_all("/", "-")
#     properties[["Type"]][i] <- paste0("[", ref_text, "](", ref_id, ")")
#     properties[["Reference"]] <- NULL
#   }

#   properties
# }
