x <- jsonlite::read_json("../mighty.metadata/inst/schema/adam.json")

str(x)

x[["title"]]
x[["description"]]

# Object properties
document_object(x[["properties"]]) |>
  knitr::kable()

# Object not properties
x[["definitions"]][["parameter"]][-3] |>
  purrr::map(as_character_1) |>
  as_character_named() |>
  tibble::enframe()

# String
x[["definitions"]][["cdisc"]][["class"]] |>
  purrr::map(as_character_1) |>
  as_character_named() |>
  tibble::enframe() |>
  doc_kable()
