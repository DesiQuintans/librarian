context("Non-standard evaluation (HEY: Tests should be run from a new R session.)")

library(librarian)

test_that("nse_dots() can accept arbitrary number of args", {
    expect_equal(length(nse_dots()), 0)
    expect_equal(length(nse_dots(dplyr)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata)), 1)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata)), 2)
})

test_that("nse_dots() returns a character vector", {
    expect_type(nse_dots(),                               "character")
    expect_type(nse_dots(dplyr),                          "character")
    expect_type(nse_dots(DesiQuintans/desiderata),        "character")
    expect_type(nse_dots(dplyr, DesiQuintans/desiderata), "character")
})

test_that("nse_dots() removes duplicated names", {
    expect_equal(length(nse_dots(dplyr, purrr, dplyr)), 2)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, DesiQuintans/desiderata)), 1)
    expect_equal(length(nse_dots(dplyr, dplyr, DesiQuintans/desiderata, DesiQuintans/desiderata)), 2)
})

test_that("nse_dots() removes username correctly", {
    expect_equal(length(nse_dots(dplyr, keep_user = TRUE)), 1)
    expect_equal(length(nse_dots(dplyr, keep_user = FALSE)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, keep_user = TRUE)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, keep_user = FALSE)), 1)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata, desiderata, keep_user = TRUE)), 3)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata, desiderata, keep_user = FALSE)), 2)
})