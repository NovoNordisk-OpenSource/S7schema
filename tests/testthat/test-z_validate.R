test_that("simple validation on lists works", {
  validate(
    x = list(id = "a"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition() |>
    expect_equal(
      expected = list(id = "a")
    )

  validate(
    x = list(fake = "b"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "must NOT have additional properties.* additionalProperty: fake"
    )

  validate(
    x = list(id = 1),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "/id.* must be string"
    )
})

test_that("simple validation of yaml files works", {
  validate(
    x = test_path("input", "simple.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_no_condition() |>
    expect_equal(
      expected = test_path("input", "simple.yml")
    )

  validate(
    x = test_path("input", "simple_error.yml"),
    schema = test_path("schemas", "simple.json")
  ) |>
    expect_error(
      "must NOT have additional properties.* additionalProperty: error"
    )
})
