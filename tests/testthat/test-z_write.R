test_that("writing works", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  )

  tmpfile <- withr::local_tempfile(fileext = ".yml")

  write_config(x = x, file = tmpfile) |>
    expect_no_condition()

  file.exists(tmpfile) |>
    expect_true()

  y <- S7schema(
    file = tmpfile,
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  expect_equal(x$id, y$id)
  expect_equal(x@schema, y@schema)
})

test_that("file property can be modified and used as default in write_config", {
  x <- S7schema(
    file = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  )

  x@file |>
    expect_equal(test_path("input", "simple.yml"))

  new_path <- withr::local_tempfile(fileext = ".yml")
  x@file <- new_path

  x@file |>
    expect_equal(new_path)

  write_config(x) |>
    expect_no_condition()

  file.exists(new_path) |>
    expect_true()

  y <- S7schema(
    file = new_path,
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition()

  expect_equal(x$id, y$id)
})
