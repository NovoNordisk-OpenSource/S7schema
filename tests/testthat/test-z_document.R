test_that("document_schema() - dispatch is consistent", {
  schema <- test_path("schemas", "simple.json")
  config <- test_path("input", "simple.yml")

  a <- document_schema(schema, 2) |>
    expect_no_condition()

  b <- schema |>
    jsonlite::read_json() |>
    document_schema(2) |>
    expect_no_condition()

  c <- S7schema(config, schema) |>
    document_schema(2) |>
    expect_no_condition()

  expect_equal(a, b)
  expect_equal(b, c)
})

test_that("document_schema() - output is consistent", {
  test_path("schemas", "simple.json") |>
    document_schema(1) |>
    expect_type("character") |>
    expect_s3_class("knit_asis") |>
    cat() |>
    expect_snapshot()

  test_path("schemas", "definitions.json") |>
    document_schema(1) |>
    expect_type("character") |>
    expect_s3_class("knit_asis") |>
    cat() |>
    expect_snapshot()
})
