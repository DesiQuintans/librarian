# https://github.com/r-lib/testthat/issues/144
Sys.setenv("R_TESTS" = "")

test_check("librarian")
