context("Installing packages from CRAN and GitHub")

library(librarian)

test_that("Install fortunes (CRAN) and emptyRpackage (GitHub)", {
    skip_on_cran()
    # R CMD CHECK doesn't get access to getOption("repos")
    expect_equal(sum(shelf(fortunes)), 1)
    expect_type(fortunes::fortune(), "list")
    expect_equal(sum(shelf(DesiQuintans/emptyRpackage)), 1)
    expect_type(emptyRpackage::hello_emptyR(), "character")
})

test_that("Try to unshelf() fortunes and emptyRpackage", {
    skip_on_cran()
    expect_equal(sum(unshelf(fortunes, DesiQuintans/emptyRpackage)), 2)
})