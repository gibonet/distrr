test_that("dcc returns the correct number of rows", {
  res <- dcc(invented_wages, "gender")
  expect_equal(nrow(res), 3L)
  
  res <- dcc(invented_wages, "education")
  expect_equal(nrow(res), 4L)
  
  l <- extract_levels(invented_wages)
  k <- sapply(l, length)
  k <- prod(k + 1)
  res <- dcc(invented_wages, names(l))
  expect_equal(k, nrow(res))
})

test_that("dcc2 returns the correct number of rows", {
  res <- dcc2(invented_wages, "gender")
  expect_equal(nrow(res), 3L)
  
  res <- dcc2(invented_wages, "education")
  expect_equal(nrow(res), 4L)
  
  l <- extract_levels(invented_wages)
  k <- sapply(l, length)
  k <- prod(k + 1)
  res <- dcc2(invented_wages, names(l))
  expect_equal(k, nrow(res))
})


test_that("dcc5 returns the correct number of rows", {
  res <- dcc5(invented_wages, "gender")
  expect_equal(nrow(res), 3L)
  
  res <- dcc5(invented_wages, "education")
  expect_equal(nrow(res), 4L)
  
  l <- extract_levels(invented_wages)
  k <- sapply(l, length)
  k <- prod(k + 1)
  res <- dcc5(invented_wages, names(l))
  expect_equal(k, nrow(res))
  
  res <- dcc5(invented_wages, names(l), .all = FALSE)
  expect_equal(k - 1, nrow(res))
})

