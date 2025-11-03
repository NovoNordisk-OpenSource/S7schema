test_that("S7schema works", {
  x <- S7schema(
    .data = test_path("input", "simple.yml"),
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
    .data = test_path("input", "simple.yml"),
    schema = "file/that/does/not/exist.json"
  ) |>
    expect_error("File does not exist")

  S7schema(
    .data = "file/that/does/not/exist.yml",
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("File does not exist")

  S7schema(
    .data = test_path("input", "simple_error.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("must NOT have additional properties")
})
