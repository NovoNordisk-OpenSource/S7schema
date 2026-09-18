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

test_that("S7schema can be initiated without YAML", {
  x <- S7schema(
    .data = list(id = "test"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  S7schema(
    .data = list(illegal = "entry"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error()

  S7schema(
    .data = "non_list_input",
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error()
})

test_that("validate_prop_schema() returns error for invalid input", {
  expect_match(validate_prop_schema("not_a_file.json"), "File does not exist")
})

test_that("validate_prop_file() returns error for invalid input", {
  expect_match(validate_prop_file("not_a_file.yml"), "File does not exist")
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

test_that("S7schema treats file = NULL as missing and uses .data", {
  S7schema(
    file = NULL,
    .data = list(id = "test"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()
})

test_that("S7schema treats .data = NULL as missing and uses file", {
  S7schema(
    file = test_path("input", "simple.yml"),
    .data = NULL,
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()
})

test_that("S7schema errors when both file and .data are NULL", {
  S7schema(
    file = NULL,
    .data = NULL,
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error()
})
