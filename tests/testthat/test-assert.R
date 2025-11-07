test_that("file assertions are correct and consistent", {
  schema <- withr::local_tempfile(fileext = ".json")

  assert_file(c("a.R", "b.R")) |>
    expect_error("Only exactly one file can be referenced")

  assert_file(file = schema) |>
    expect_error("File does not exist")

  writeLines(
    text = "hello: world",
    con = schema
  )

  assert_file(file = schema, ext = "fake") |>
    expect_error("Extension must be one")

  assert_file(file = schema) |>
    expect_equal(schema)

  assert_file(file = schema, ext = "json") |>
    expect_equal(schema)
})

test_that("file checking is consistent", {
  schema <- withr::local_tempfile(fileext = ".json")

  check_file(file = schema, ext = "json") |>
    expect_equal("File does not exist")

  writeLines(
    text = "hello: world",
    con = schema
  )

  check_file(file = schema, ext = "json") |>
    expect_true()
})
