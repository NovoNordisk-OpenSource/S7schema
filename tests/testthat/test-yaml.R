test_that("logical is always converted to true/false", {
  to_yaml(TRUE) |>
    expect_equal("true\n")

  to_yaml(FALSE) |>
    expect_equal("false\n")

  to_yaml(c(TRUE, FALSE, FALSE, NA)) |>
    expect_equal("- true\n- false\n- false\n- NA\n")

  list(id = "a string", y = FALSE) |>
    to_yaml() |>
    expect_no_condition() |>
    expect_equal("id: a string\n'y': false\n")
})
