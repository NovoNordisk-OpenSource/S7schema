test_that("simple validation on lists works", {
  validate_list(
    x = list(id = "a"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition() |>
    expect_equal(
      expected = list(id = "a")
    )

  validate_list(
    x = list(fake = "b"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "\\(root\\) must NOT have additional properties.* additionalProperty: fake"
    )

  validate_list(
    x = list(id = 1),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "/id.* must be string"
    )
})

test_that("array validation errors use 1-based indexing", {
  validate_list(
    x = list(my_array = list("a", "b")),
    schema = test_path("schemas", "array.json")
  ) |>
    expect_no_condition()

  validate_list(
    x = list(my_array = list("a", 1)),
    schema = test_path("schemas", "array.json")
  ) |>
    expect_error("/my_array/2 must be string")
})

test_that("simple validation of yaml files works", {
  validate_yaml(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition() |>
    expect_equal(
      expected = test_path("input", "simple.yml")
    )

  validate_yaml(
    file = test_path("input", "simple_error.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "\\(root\\) must NOT have additional properties.* additionalProperty: error"
    )
})


test_that("validate_yaml includes file path in error messages", {
  expect_error(
    validate_yaml(
      file = test_path("input", "simple_error.yml"),
      schema = test_path("schemas", "simple.json")
    ),
    regexp = "simple_error\\.yml"
  )
})

test_that("oneOf shows all sub-errors for invalid input", {
  validate_list(
    x = list(value = "ABC123"),
    schema = test_path("schemas", "oneof_pattern.json")
  ) |>
    expect_error("must match exactly one schema in oneOf")
})

test_that("oneOf with $ref shows all sub-errors", {
  expect_error(
    validate_list(
      x = list(value = list("ABC")),
      schema = test_path("schemas", "oneof_ref.json")
    ),
    regexp = "(?s)must be string.*must match pattern",
    perl = TRUE
  )
})

test_that("oneOf still validates correct input", {
  validate_list(
    x = list(value = "abc"),
    schema = test_path("schemas", "oneof_pattern.json")
  ) |>
    expect_no_condition()

  validate_list(
    x = list(value = list("abc", "def")),
    schema = test_path("schemas", "oneof_pattern.json")
  ) |>
    expect_no_condition()
})
