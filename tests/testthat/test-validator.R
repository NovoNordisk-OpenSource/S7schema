test_that("fix_path", {
  # single numeric segment
  expect_equal(fix_path("/items/0"), "/items/1")
  expect_equal(fix_path("/items/1"), "/items/2")

  # multiple numeric segments
  expect_equal(fix_path("/a/0/b/2"), "/a/1/b/3")

  # no numeric segments — unchanged
  expect_equal(fix_path("/foo/bar"), "/foo/bar")

  # empty path returns (root)
  expect_equal(fix_path(""), "(root)")

  # root-level numeric segment
  expect_equal(fix_path("/0"), "/1")
})

test_that("to_json", {
  expect_equal(to_json(NULL), "null")
  expect_equal(to_json(list()), "[]")
  expect_equal(to_json(rlang::set_names(list(), character())), "{}")
  expect_equal(to_json(list(a = NULL, b = NA)), '{"a":null,"b":null}')
  expect_equal(to_json(list(a = "x", b = c(1, 2))), '{"a":"x","b":[1,2]}')
  expect_equal(to_json(pi), "3.1415926535897931")
})

test_that("validator loads the bundle and resolves $ref in definitions", {
  v <- validator(schema = test_path("schemas", "definitions.json"))

  expect_s3_class(v@context, "JSContext")

  use_validator(
    validator = v,
    data = list(id = "a", keys = list("x", "y"), do_something = TRUE)
  ) |>
    expect_no_condition()

  use_validator(validator = v, data = list(id = "a", keys = 1)) |>
    expect_error("/keys must match exactly one schema in oneOf")

  use_validator(
    validator = v,
    data = list(id = "a", keys = "x", do_something = "yes")
  ) |>
    expect_error("/do_something must be boolean")
})

test_that("strings with escapes and non-ASCII characters are passed safely", {
  v <- validator(schema = test_path("schemas", "strings.json"))

  values <- c(
    "\u00e6\u00f8\u00e5 \u00c6\u00d8\u00c5",
    "\U0001F600",
    "double \" and single ' quotes",
    "back\\slash",
    "new\nline and\ttab",
    "</script> $x `y`"
  )

  for (value in values) {
    use_validator(validator = v, data = list(text = value)) |>
      expect_no_condition()
  }

  use_validator(
    validator = v,
    data = list(text = "\u00e6\u00f8 \U0001F600")
  ) |>
    expect_error("current value: .*\u00e6\u00f8 \U0001F600")

  use_validator(validator = v, data = list(text = "back\\\\slash")) |>
    expect_error("/text must be equal to one of the allowed values")
})
