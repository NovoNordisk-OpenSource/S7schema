test_that("schema checking is consistent", {
  schema <- withr::local_tempfile(fileext = ".json")

  check_schema(schema = schema) |>
    expect_equal("File does not exist")

  writeLines(
    text = "hello: world",
    con = schema
  )

  check_schema(schema = schema) |>
    expect_true()
})

test_that("schema assertations errors correctly", {
  schema <- withr::local_tempfile(fileext = ".json")

  assert_schema(schema = schema) |>
    expect_error("File does not exist")

  writeLines(
    text = "hello: world",
    con = schema
  )

  assert_schema(schema = schema) |>
    expect_equal(schema)
})
