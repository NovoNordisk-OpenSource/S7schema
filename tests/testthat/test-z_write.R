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

  expect_equal(S7::S7_data(x), S7::S7_data(y))
  expect_equal(x@schema, y@schema)
})
