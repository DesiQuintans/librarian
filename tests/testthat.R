# https://github.com/r-lib/testthat/issues/144
Sys.setenv("R_TESTS" = "")

library(testthat)
library(librarian)

test_check("librarian")

