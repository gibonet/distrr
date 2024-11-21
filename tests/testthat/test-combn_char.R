test_that("combn_char returns a list of same length as input vector", {
  x <- c("sector")
  l <- combn_char(x)
  
  expect_equal(length(x), length(l))
  expect_type(l, type = "list")
  rm(x, l)
})
