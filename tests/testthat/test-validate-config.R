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

test_that("errors include the current value when it is a scalar", {
  # numeric value shown unquoted
  validate_list(
    x = list(id = 1),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("current value: 1")

  # string value shown quoted, so the type is visible
  validate_list(
    x = list(do_something = "yes"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error('current value: "yes"')

  # array element reports the element, not the whole array
  validate_list(
    x = list(my_array = list("a", 1)),
    schema = test_path("schemas", "array.json")
  ) |>
    expect_error("current value: 1")

  # oneOf errors also report the value
  validate_list(
    x = list(value = "ABC123"),
    schema = test_path("schemas", "oneof_pattern.json")
  ) |>
    expect_error('current value: "ABC123"')
})

test_that("errors omit the current value when it is not a scalar", {
  # object-level keywords report the whole object as the failing value, which
  # would dump the entire config into the error message
  expect_error(
    validate_list(
      x = list(fake = "b"),
      schema = test_path("schemas", "simple.json")
    ),
    regexp = "must NOT have additional properties"
  ) |>
    conditionMessage() |>
    expect_no_match("current value")
})

test_that("oneOf shows all sub-errors for invalid input", {
  validate_list(
    x = list(value = "ABC123"),
    schema = test_path("schemas", "oneof_pattern.json")
  ) |>
    expect_error("must match exactly one schema in oneOf")
})

test_that("oneOf with $ref shows all sub-errors", {
  # Two items, since R reads a one-item sequence back as a single value
  expect_error(
    validate_list(
      x = list(value = list("abc", "ABC")),
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

test_that("unquoted date-like values are validated as strings", {
  # yaml::read_yaml() reads 2025-08-06 as a string, so the schema check for a
  # string must pass. See #67.
  validate_yaml(
    file = test_path("input", "date_string.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  validate_list(
    x = list(id = "2025-08-06"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()
})

test_that("merge keys are resolved as R's yaml reader resolves them", {
  # `<<: *anchor` must still merge, so that the validated data and the list
  # read by yaml::read_yaml() stay the same. See #67.
  validate_yaml(
    file = test_path("input", "merge_key.yml"),
    schema = test_path("schemas", "merge.json")
  ) |>
    expect_no_condition()
})

test_that("validate_yaml() validates the values read by yaml::read_yaml()", {
  file <- test_path("input", "r_types.yml")
  content <- yaml::read_yaml(file)

  # yes is a boolean, the merge key wins, and date-like or number-like values
  # are strings. See #70.
  expect_true(content$flag)
  expect_equal(content$merged$b, 2L)
  expect_equal(content$date, "2025-08-06")
  expect_equal(content$numbers, c("1e3", "0o17"))
  expect_equal(content$id, "0b101")

  validate_yaml(
    file = file,
    schema = test_path("schemas", "r_types.json")
  ) |>
    expect_no_condition()

  # no is read as FALSE, and the error shows the R value
  validate_yaml(
    file = test_path("input", "no_string.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("(?s)/id.* must be string.*current value: FALSE", perl = TRUE)
})

test_that("validate_list() validates the values R reads back", {
  schema <- test_path("schemas", "simple.json")

  # number-like strings stay strings
  validate_list(x = list(id = "1e3"), schema = schema) |>
    expect_no_condition()

  validate_list(x = list(id = "0b101"), schema = schema) |>
    expect_no_condition()

  # dates are strings
  validate_list(x = list(id = as.Date("2025-08-06")), schema = schema) |>
    expect_no_condition()

  # missing values are null
  validate_list(x = list(id = NA_character_), schema = schema) |>
    expect_error("/id.* must be string")

  validate_list(x = list(id = NA), schema = schema) |>
    expect_error("/id.* must be string")

  # numbers keep 15 significant digits
  validate_list(
    x = list(pi = pi),
    schema = test_path("schemas", "precision.json")
  ) |>
    expect_no_condition()
})

test_that("files, lists, and S7schema objects give the same result", {
  passes <- function(expr) {
    tryCatch(
      expr = {
        force(expr)
        TRUE
      },
      error = \(e) FALSE
    )
  }

  cases <- list(
    list(file = "simple.yml", schema = "simple.json", valid = TRUE),
    list(file = "simple_error.yml", schema = "simple.json", valid = FALSE),
    list(file = "date_string.yml", schema = "simple.json", valid = TRUE),
    list(file = "no_string.yml", schema = "simple.json", valid = FALSE),
    list(file = "merge_key.yml", schema = "merge.json", valid = TRUE),
    list(file = "r_types.yml", schema = "r_types.json", valid = TRUE)
  )

  for (case in cases) {
    file <- test_path("input", case$file)
    schema <- test_path("schemas", case$schema)

    results <- c(
      validate_yaml = passes(validate_yaml(file = file, schema = schema)),
      validate_list = passes(validate_list(x = yaml::read_yaml(file), schema)),
      S7schema = passes(S7schema(file = file, schema = schema))
    )

    expect_equal(
      object = results,
      expected = c(
        validate_yaml = case$valid,
        validate_list = case$valid,
        S7schema = case$valid
      ),
      label = case$file
    )
  }
})

test_that("empty files and lists are validated as R reads them", {
  # an empty file is read as NULL
  validate_yaml(
    file = test_path("input", "empty.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("\\(root\\) must be object")

  validate_yaml(
    file = test_path("input", "empty.yml"),
    schema = test_path("schemas", "nullable.json")
  ) |>
    expect_no_condition()

  # a named empty list is an object, an unnamed empty list is an array
  validate_list(
    x = rlang::set_names(list(), character()),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  validate_list(
    x = list(),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error("\\(root\\) must be object")
})
