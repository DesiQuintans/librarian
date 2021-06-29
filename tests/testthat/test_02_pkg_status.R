context("Testing functions that check package status")


# Test package status-checking functions ----------------------------------

test_that("check_installed() lists all installed packages when dots is empty.", {
    skip_on_cran()
    expect_identical(
        check_installed(), 
        rownames(utils::installed.packages()))
})


test_that("check_installed() evaluates dots correctly.", {
    skip_on_cran()
    expect_identical(
        check_installed(datasets, utils, fakepkg),
        c(datasets = TRUE, utils = TRUE, fakepkg = FALSE))
    expect_identical(
        check_installed("datasets", utils, "fakepkg"),
        c(datasets = TRUE, utils = TRUE, fakepkg = FALSE))
    expect_identical(
        check_installed(c("datasets", "utils"), "fakepkg"),
        c(datasets = TRUE, utils = TRUE))
})


test_that("check_attached() lists all attached packages when dots is empty.", {
    skip_on_cran()
    expect_identical(
        check_attached(), 
        .packages())
})


test_that("check_attached() evaluates dots correctly.", {
    skip_on_cran()
    expect_identical(
        check_attached(datasets, utils, fakepkg),
        c(datasets = TRUE, utils = TRUE, fakepkg = FALSE))
    expect_identical(
        check_attached("datasets", utils, "fakepkg"),
        c(datasets = TRUE, utils = TRUE, fakepkg = FALSE))
    expect_identical(
        check_attached(c("datasets", "utils"), "fakepkg"),
        c(datasets = TRUE, utils = TRUE))
})


test_that("list_dependencies() is working.", {
    skip_on_cran()
    expect_identical(
        list_dependencies("datasets"),
        character(0))
    
    expect_identical(
        list_dependencies("testthat"),
        c("brio", "callr", "cli", "crayon", "desc", "digest", "ellipsis", "evaluate", 
          "jsonlite", "lifecycle", "magrittr", "methods", "pkgload", "praise", "processx", 
          "ps", "R6", "rlang", "utils", "waldo", "withr"))
    
    expect_identical(
        list_dependencies(c("datasets", "testthat")),  # NULL will be removed.
        c("brio", "callr", "cli", "crayon", "desc", "digest", "ellipsis", "evaluate", 
          "jsonlite", "lifecycle", "magrittr", "methods", "pkgload", "praise", "processx", 
          "ps", "R6", "rlang", "utils", "waldo", "withr"))
})
