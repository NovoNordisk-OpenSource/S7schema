test_that("fix_path", {
  # single numeric segment
  expect_equal(fix_path("/items/0"), "/items/1")
  expect_equal(fix_path("/items/1"), "/items/2")

  # multiple numeric segments
  expect_equal(fix_path("/a/0/b/2"), "/a/1/b/3")

  # no numeric segments — unchanged
  expect_equal(fix_path("/foo/bar"), "/foo/bar")

  # empty path returns (root)
  expect_equal(fix_path(""), "(root)")

  # root-level numeric segment
  expect_equal(fix_path("/0"), "/1")
})
