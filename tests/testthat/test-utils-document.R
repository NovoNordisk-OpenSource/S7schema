test_that("doc_text()", {
  doc_text(NULL) |>
    expect_null()

  doc_text(1) |>
    expect_equal("1")

  doc_text(c("hello", "world")) |>
    expect_equal("hello\n\nworld")
})

test_that("doc_header()", {
  doc_header("my title", 3) |>
    expect_equal("### my title")

  doc_header(c("my", "title"), 2) |>
    expect_equal("## my title")
})

test_that("doc_repair_names()", {
  doc_repair_names(1) |>
    expect_equal(1)

  doc_repair_names(c("a" = 1, "hello world" = 2)) |>
    expect_equal(c("A" = 1, "Hello World" = 2))
})

test_that("doc_yesno()", {
  doc_yesno(FALSE) |>
    expect_equal("No")

  doc_yesno(TRUE) |>
    expect_equal("Yes")

  doc_yesno(c(TRUE, FALSE)) |>
    expect_equal(c("Yes", "No"))

  data.frame(
    a = 1:3,
    b = c(TRUE, TRUE, FALSE)
  ) |>
    doc_yesno() |>
    expect_equal(
      data.frame(
        a = 1:3,
        b = c("Yes", "Yes", "No")
      )
    )

  doc_yesno(mtcars) |>
    expect_equal(mtcars)
})

test_that("doc_ref_type()", {
  doc_ref_type(mtcars) |>
    expect_equal(mtcars)

  data.frame(
    "$ref" = "reference",
    check.names = FALSE
  ) |>
    doc_ref_type() |>
    expect_equal(
      data.frame(
        type = "reference"
      )
    )

  data.frame(
    "$ref" = c(NA_character_, "reference"),
    type = c("string", NA_character_),
    check.names = FALSE
  ) |>
    doc_ref_type() |>
    expect_equal(
      data.frame(
        type = c("string", "reference")
      )
    )
})

test_that("doc_hyperlink()", {
  doc_hyperlink(1) |>
    expect_equal(1)

  doc_hyperlink(c("a", "b")) |>
    expect_equal(c("a", "b"))

  doc_hyperlink("hello") |>
    expect_equal("hello")

  doc_hyperlink("#/definitions/my_reference") |>
    expect_equal("[my_reference](#my_reference)")

  doc_hyperlink("#/definitions/category/my_reference") |>
    expect_equal("[category/my_reference](#my_reference)")
})

test_that("doc_ref_hyperlinks()", {
  doc_ref_hyperlinks("a") |>
    expect_equal("a")

  list(
    a = 1,
    b = list(
      c = "hello",
      d = "#/definitions/my_reference"
    )
  ) |>
    doc_ref_hyperlinks() |>
    expect_equal(
      list(
        a = 1,
        b = list(
          c = "hello",
          d = "[my_reference](#my_reference)"
        )
      )
    )
})

test_that("doc_kable()", {
  data.frame(
    a = 1:5,
    b = letters[1:5],
    c = TRUE
  ) |>
    doc_kable() |>
    expect_type("character") |>
    expect_length(1)
})

test_that("as_character_1()", {
  as_character_1(1, "") |>
    expect_equal("1")

  as_character_1(TRUE, "-") |>
    expect_equal("Yes")

  as_character_1(FALSE, "-") |>
    expect_equal("No")

  as_character_1(c(TRUE, FALSE, FALSE), "-") |>
    expect_equal("Yes-No-No")

  as_character_1(c("a", "b", "c"), "-") |>
    expect_equal("a-b-c")
})
