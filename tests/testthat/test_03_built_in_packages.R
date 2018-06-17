context("Attaching, detaching, and reattaching built-in packages")

library(librarian)

# 'datasets' package is used because trying to use a non-default built-in package (boot,
# mgcv) in R CMD CHECK returns an error about those packages not existing. Seems like R
# CMD CHECK doesn't actually have a library. So that's why I use a package that I know is
# already loaded at startup.

test_that("'datasets' is attached by default, so unattach it.", {
    skip_on_cran()
    expect_null(detach("package:datasets", unload = TRUE, character.only = TRUE))
    expect_equal(sum(check_attached(nse_dots(datasets))), 0)
})

test_that("Try to shelf() datasets", {
    skip_on_cran()
    expect_equal(sum(shelf(datasets)), 1)
})

test_that("Try to unshelf() datasets", {
    skip_on_cran()
    # Has to be safe = FALSE or else R CMD CHECK is unhappy.
    expect_equal(sum(unshelf(datasets, safe = FALSE)), 1)
})

test_that("Try to reshelf() datasets", {
    skip_on_cran()
    expect_equal(sum(reshelf(datasets)), 1)
})