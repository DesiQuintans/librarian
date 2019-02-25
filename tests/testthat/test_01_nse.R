context("Non-standard evaluation (HEY: Tests should be run in a new R session.)")

library(librarian)

test_that("nse_dots() can accept an arbitrary number of args", {
    skip_on_cran()
    expect_equal(length(nse_dots()), 0)
    expect_equal(length(nse_dots(dplyr)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata)), 1)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata)), 2)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata, phyloseq)), 3)
})

test_that("nse_dots() should return a character vector", {
    skip_on_cran()
    expect_type(nse_dots(),                               "character")
    expect_type(nse_dots(dplyr),                          "character")
    expect_type(nse_dots(DesiQuintans/desiderata),        "character")
    expect_type(nse_dots(dplyr, DesiQuintans/desiderata), "character")
})

test_that("nse_dots() should allow letters, numbers, - . _ ~ : and /", {
    skip_on_cran()
    # https://stackoverflow.com/a/7109208/5578429
    # But not all of the characters are accepted inside R symbols.
    test <- "A1B2C3D4E5F6G7H8I9J0K-L.M_N~O:P/QRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    expect_identical(nse_dots(A1B2C3D4E5F6G7H8I9J0K-L.M_N~O:P/QRSTUVWXYZabcdefghijklmnopqrstuvwxyz, keep_user = TRUE), 
                     c("A1B2C3D4E5F6G7H8I9J0K-L.M_N~O:P/QRSTUVWXYZabcdefghijklmnopqrstuvwxyz"))
})

test_that("A character vector passed to nse_dots() should not be changed even if it has special characters", {
    skip_on_cran()
    # https://stackoverflow.com/a/7109208/5578429
    expect_identical(nse_dots("A1B2C3D4E5F6G7H8I9J0K-L.M_N~O:P/Q?R#S[T]U@V!W$X$Y&Z'a(b)c*d+e,f;g=hijklmnopqrstuvwxyz", keep_user = TRUE),
                     "A1B2C3D4E5F6G7H8I9J0K-L.M_N~O:P/Q?R#S[T]U@V!W$X$Y&Z'a(b)c*d+e,f;g=hijklmnopqrstuvwxyz")
})

test_that("A user can pass a mixture of bare names and strings to nse_dots()", {
    skip_on_cran()
    expect_identical(nse_dots(barename, bare-name, bare.name, "stringname", "string-name", "string.name"),
                     c("barename", "bare-name", "bare.name", "stringname", "string-name", "string.name"))
})

test_that("nse_dots() removes duplicated names", {
    skip_on_cran()
    expect_equal(length(nse_dots(dplyr, purrr, dplyr)), 2)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, DesiQuintans/desiderata)), 1)
    expect_equal(length(nse_dots(dplyr, dplyr, DesiQuintans/desiderata, DesiQuintans/desiderata)), 2)
})

test_that("nse_dots() removes (or keeps) the username correctly", {
    skip_on_cran()
    expect_equal(length(nse_dots(dplyr, keep_user = TRUE)), 1)
    expect_equal(length(nse_dots(dplyr, keep_user = FALSE)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, keep_user = TRUE)), 1)
    expect_equal(length(nse_dots(DesiQuintans/desiderata, keep_user = FALSE)), 1)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata, desiderata, keep_user = TRUE)), 3)
    expect_equal(length(nse_dots(dplyr, DesiQuintans/desiderata, desiderata, keep_user = FALSE)), 2)
})
