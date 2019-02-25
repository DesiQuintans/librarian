context("Listing installed and attached packages")

library(librarian)


# check_installed() -----------------------------------------------------------------

test_that("check_installed() can accept a first arg of arbitrary length", {
    skip_on_cran()
    expect_equal(length(check_installed()), length(rownames(utils::installed.packages())))
    expect_equal(sum(check_installed("mgcv")), 1)
    expect_equal(sum(check_installed(c("mgcv", "boot"))), 2)
})

test_that("check_installed() with empty first arg returns vector of installed packages", {
    skip_on_cran()
    expect_type(check_installed(), "character")
})

test_that("check_installed() with non-empty first arg returns a logical vector", {
    skip_on_cran()
    expect_type(check_installed("mgcv"), "logical")
    expect_type(check_installed(c("mgcv", "boot")), "logical")
})


# check_attached() ------------------------------------------------------------------


test_that("check_attached() can accept arbitrary number of args", {
    skip_on_cran()
    expect_equal(length(check_attached()), length(.packages()))
    expect_equal(length(check_attached("boot")), 1)
    expect_equal(length(check_attached(c("mgcv", "boot"))), 2)
})

test_that("check_attached() with empty first arg returns a character vector", {
    skip_on_cran()
    expect_type(check_attached(), "character")
})

test_that("check_attached() returns a logical vector", {
    skip_on_cran()
    expect_type(check_attached("dplyr"), "logical")
    expect_type(check_attached(c("mgcv", "boot")), "logical")
})
