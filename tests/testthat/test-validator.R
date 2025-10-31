test_that("simple validation works", {
  validator <- schema_validator(schema = test_path("schemas", "simple.json")) |>
    expect_no_condition()

  validate_schema(x = validator, list(id = "a")) |>
    expect_no_condition() |>
    expect_equal(list(id = "a"))

  validate_schema(x = validator, list(fake = "b")) |>
    expect_error(
      "must NOT have additional properties.* additionalProperty: fake"
    )
})
