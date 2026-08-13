test_that("writing works", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  )

  tmpfile <- withr::local_tempfile(fileext = ".yml")

  write_config(x = x, path = tmpfile) |>
    expect_no_condition()

  file.exists(tmpfile) |>
    expect_true()

  y <- S7schema(
    file = tmpfile,
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  expect_equal(S7::S7_data(x), S7::S7_data(y))
  expect_equal(x@schema, y@schema)
})

test_that("default for S7schema class", {
  tmpfile <- withr::local_tempfile(
    lines = readLines(test_path("input", "simple.yml")),
    fileext = ".yml"
  )

  x <- S7schema(
    file = tmpfile,
    schema = test_path("schemas", "simple.json")
  )

  expect_equal(x$id, "abc")

  x$id <- "d"

  write_config(x) |>
    expect_no_condition()

  y <- S7schema(
    file = tmpfile,
    schema = test_path("schemas", "simple.json")
  )

  expect_equal(y$id, "d")
})

test_that("object created in memory", {
  x <- S7schema(
    .data = list(id = "test"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  write_config(x) |>
    expect_error("`path` must be provided")

  tmpfile <- withr::local_tempfile(
    fileext = ".yml"
  )

  x$id <- "d"

  write_config(x, tmpfile) |>
    expect_no_condition()

  y <- S7schema(
    file = tmpfile,
    schema = test_path("schemas", "simple.json")
  )

  expect_equal(y$id, "d")
})
