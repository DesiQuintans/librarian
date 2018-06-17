context("Installing packages from CRAN and GitHub")

library(librarian)

test_that("Install fortunes (CRAN) and emptyRpackage (GitHub)", {
    skip_on_cran()
    expect_equal(sum(shelf(fortunes)), 1)
    expect_type(fortunes::fortune(), "list")
    
    expect_equal(sum(shelf(DesiQuintans/emptyRpackage)), 1)
    expect_type(emptyRpackage::hello_emptyR(), "character")
})

test_that("Try to unshelf() fortunes and emptyRpackage", {
    skip_on_cran()
    expect_equal(sum(unshelf(fortunes, DesiQuintans/emptyRpackage)), 2)
})

test_that("Try to reshelf() fortunes and emptyRpackage together", {
    skip_on_cran()
    expect_equal(sum(reshelf(fortunes, DesiQuintans/emptyRpackage)), 2)
})

test_that("Unshelf() to clean the environment", {
    skip_on_cran()
    expect_equal(sum(unshelf(fortunes, DesiQuintans/emptyRpackage)), 2)
    expect_equal(sum(check_attached(nse_dots(fortunes, emptyRpackage))), 0)
})