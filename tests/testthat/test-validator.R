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

test_that("to_json", {
  expect_equal(to_json(NULL), "null")
  expect_equal(to_json(list()), "[]")
  expect_equal(to_json(rlang::set_names(list(), character())), "{}")
  expect_equal(to_json(list(a = NULL, b = NA)), '{"a":null,"b":null}')
  expect_equal(to_json(list(a = "x", b = c(1, 2))), '{"a":"x","b":[1,2]}')
  expect_equal(to_json(pi), "3.14159265358979")
})
