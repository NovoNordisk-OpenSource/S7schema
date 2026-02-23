test_that("S7schema works", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  x$id <- "a"

  validate(x) |>
    expect_no_condition()

  x$illegal_entry <- 1

  validate(x) |>
    expect_error()
})

test_that("S7schema throws errors with wrong input", {
  S7schema(
    file = test_path("input", "simple.yml"),
    schema = "file/that/does/not/exist.json"
  ) |>
    expect_error("File does not exist")

  S7schema(
    file = "file/that/does/not/exist.yml",
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("File does not exist")

  S7schema(
    file = test_path("input", "simple_error.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("must NOT have additional properties")
})

test_that("S7schema includes file path in validation error messages", {
  # Test schema validation error includes file name
  expect_error(
    S7schema(
      file = test_path("input", "simple_error.yml"),
      schema = test_path("schemas", "simple.json")
    ),
    regexp = "simple_error\\.yml"
  )
})

test_that("validate() on modified S7schema still includes file reference", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  )

  x$illegal_entry <- 1

  # Should error and still reference the original file (stored in object)
  expect_error(
    validate(x),
    regexp = "simple\\.yml"
  )
})
