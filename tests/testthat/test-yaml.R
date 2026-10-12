test_that("logical is always converted to true/false", {
  to_yaml(TRUE) |>
    expect_equal("true\n")

  to_yaml(FALSE) |>
    expect_equal("false\n")

  to_yaml(c(TRUE, FALSE, FALSE, NA)) |>
    expect_equal("- true\n- false\n- false\n- .na\n")

  list(id = "a string", y = FALSE) |>
    to_yaml() |>
    expect_no_condition() |>
    expect_equal("id: a string\n'y': false\n")
})

test_that("logical NA is read back as NA", {
  list(a = NA, b = c(TRUE, NA)) |>
    to_yaml() |>
    yaml::yaml.load() |>
    expect_equal(list(a = NA, b = c(TRUE, NA)))
})

test_that("missing values are written with typed .na tags", {
  x <- list(
    l = NA,
    c = NA_character_,
    i = NA_integer_,
    r = NA_real_
  )

  to_yaml(x) |>
    expect_equal("l: .na\nc: .na.character\ni: .na.integer\nr: .na.real\n")

  x |>
    to_yaml() |>
    yaml::yaml.load() |>
    expect_identical(x)
})

test_that("dates are written as ISO 8601 strings", {
  to_yaml(as.Date("2025-08-06")) |>
    expect_equal("'2025-08-06'\n")

  list(a = as.Date(c("2025-08-06", NA))) |>
    to_yaml() |>
    yaml::yaml.load() |>
    expect_equal(list(a = c("2025-08-06", NA)))
})

test_that("numbers keep 15 significant digits", {
  pi |>
    to_yaml() |>
    yaml::yaml.load() |>
    expect_equal(pi, tolerance = 1e-14)
})
