context("Installing packages from CRAN and GitHub")

library(librarian)

test_that("Install fortunes (CRAN) and emptyRpackage (GitHub)", {
    skip_on_cran()
    expect_equal(sum(shelf(fortunes, lib = tempdir(), quiet = TRUE, update_all = TRUE)), 1)
    expect_type(fortunes::fortune(), "list")
    expect_equal(sum(shelf(DesiQuintans/emptyRpackage, lib = tempdir(), quiet = TRUE, update_all = TRUE)), 1)
    expect_type(emptyRpackage::hello_emptyR(), "character")
})

test_that("Check 'cran_repo' error catching and 'quiet' compliance.", {
    skip_on_cran()
    expect_warning(shelf(fortunes, lib = tempdir(), cran_repo = "this is not a URL"))
    expect_silent(shelf(fortunes, lib = tempdir(), quiet = TRUE, cran_repo = "this is not a URL"))
})

test_that("Try to unshelf() fortunes and emptyRpackage", {
    skip_on_cran()
    expect_equal(sum(unshelf(fortunes, DesiQuintans/emptyRpackage, safe = FALSE)), 2)
})

