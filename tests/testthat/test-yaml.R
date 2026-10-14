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
  yaml_round_trip(list(a = NA, b = c(TRUE, NA))) |>
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

  yaml_round_trip(x) |>
    expect_identical(x)
})

test_that("dates are written as ISO 8601 strings", {
  to_yaml(as.Date("2025-08-06")) |>
    expect_equal("'2025-08-06'\n")

  yaml_round_trip(list(a = as.Date(c("2025-08-06", NA)))) |>
    expect_equal(list(a = c("2025-08-06", NA)))
})

test_that("numbers with up to 16 significant digits are read back exactly", {
  x <- c(
    0.1,
    1.5,
    123456.789,
    1.234567890123456,
    9.876543210987654e-10,
    1.111111111111111e15
  )

  yaml_round_trip(x) |>
    expect_identical(x)

  # numbers that need 17 significant digits are rounded
  yaml_round_trip(0.1 + 0.2) |>
    expect_identical(0.3)
})
