context("Listing installed and attached packages")

library(librarian)


# check_installed() -----------------------------------------------------------------


test_that("check_installed() can accept arbitrary number of args", {
    expect_equal(length(check_installed()), length(rownames(utils::installed.packages())))
    expect_equal(length(check_installed(nse_dots(dplyr))), 1)
    expect_equal(length(check_installed(nse_dots(DesiQuintans/desiderata))), 1)
    expect_equal(length(check_installed(nse_dots(dplyr, DesiQuintans/desiderata))), 2)
})

test_that("check_installed() returns a character vector", {
    expect_type(check_installed(),                                       "character")
    expect_type(check_installed(nse_dots(dplyr)),                          "logical")
    expect_type(check_installed(nse_dots(DesiQuintans/desiderata)),        "logical")
    expect_type(check_installed(nse_dots(dplyr, DesiQuintans/desiderata)), "logical")
})

test_that("check_installed() with args returns correct number of installed packages", {
    expect_equal(sum(check_installed(nse_dots(dplyr, purrr, dplyr))), 2)
    expect_equal(sum(check_installed(c("dplyr", "purrr", "dplyr"))), 3)
    expect_equal(sum(check_installed(nse_dots(desiderata, DesiQuintans/desiderata))), 1)
    expect_equal(sum(check_installed(nse_dots(librarian, utils, desiderata, UTILS, FAKEPKG))), 3)
    expect_equal(sum(!check_installed(nse_dots(librarian, utils, desiderata, UTILS, FAKEPKG))), 2)
})


# check_attached() ------------------------------------------------------------------


test_that("check_attached() can accept arbitrary number of args", {
    expect_equal(length(check_attached()), length(.packages()))
    expect_equal(length(check_attached(nse_dots(dplyr))), 1)
    expect_equal(length(check_attached(nse_dots(DesiQuintans/desiderata))), 1)
    expect_equal(length(check_attached(nse_dots(dplyr, DesiQuintans/desiderata))), 2)
})

test_that("check_attached() returns a character vector", {
    expect_type(check_attached(),                                       "character")
    expect_type(check_attached(nse_dots(dplyr)),                          "logical")
    expect_type(check_attached(nse_dots(DesiQuintans/desiderata)),        "logical")
    expect_type(check_attached(nse_dots(dplyr, DesiQuintans/desiderata)), "logical")
})

test_that("check_attached() with args returns correct number of attached packages", {
    expect_equal(sum(check_attached(nse_dots(librarian, utils, purrr, dplyr))), 2)
    expect_equal(sum(check_attached(c("librarian", "utils", "purrr", "dplyr"))), 2)
    expect_equal(sum(check_attached(nse_dots(librarian, DesiQuintans/librarian))), 1)
    expect_equal(sum(check_attached(nse_dots(librarian, utils, desiderata, UTILS, FAKEPKG))), 2)
    expect_equal(sum(!check_attached(nse_dots(librarian, utils, desiderata, UTILS, FAKEPKG))), 3)
})
