test_that("fix_index", {
  # single numeric segment
  expect_equal(fix_index("/items/0"), "/items/1")
  expect_equal(fix_index("/items/1"), "/items/2")

  # multiple numeric segments
  expect_equal(fix_index("/a/0/b/2"), "/a/1/b/3")

  # no numeric segments — unchanged
  expect_equal(fix_index("/foo/bar"), "/foo/bar")

  # empty path
  expect_equal(fix_index(""), "")

  # root-level numeric segment
  expect_equal(fix_index("/0"), "/1")
})
