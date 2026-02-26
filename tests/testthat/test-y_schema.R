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
  err <- expect_error(
    S7schema(
      file = test_path("input", "simple_error.yml"),
      schema = test_path("schemas", "simple.json")
    ),
    regexp = "simple_error\\.yml"
  )
  expect_match(deparse(err$call), "validate_yaml")
})

test_that("validate() on modified S7schema still does not include file reference", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  )

  x$illegal_entry <- 1

  err <- expect_error(validate(x))
  expect_no_match(conditionMessage(err), "simple\\.yml")
})
