context("Listing installed and attached packages")

library(librarian)

# Trying to reduce problems in this test by using mgcv and boot, which are pre-installed
# default packages. But then I call them as if they are GitHub packages, knowing that the
# username component is going to be removed by nse_dots() anyway.

# check_installed() -----------------------------------------------------------------


test_that("check_installed() can accept arbitrary number of args", {
    skip_on_cran()
    expect_equal(length(check_installed()), length(rownames(utils::installed.packages())))
    expect_equal(length(check_installed(nse_dots(mgcv))), 1)
    expect_equal(length(check_installed(nse_dots(DesiQuintans/boot))), 1)
    expect_equal(length(check_installed(nse_dots(mgcv, DesiQuintans/boot))), 2)
})

test_that("check_installed() returns a logical vector", {
    skip_on_cran()
    expect_type(check_installed(), "character")
    expect_type(check_installed(nse_dots(mgcv)), "logical")
    expect_type(check_installed(nse_dots(DesiQuintans/boot)), "logical")
    expect_type(check_installed(nse_dots(mgcv, DesiQuintans/boot)), "logical")
})

test_that("check_installed() with args returns correct number of installed packages", {
    skip_on_cran()
    expect_equal(sum(check_installed(nse_dots(mgcv, boot, mgcv))), 2)
    expect_equal(sum(check_installed(c("boot", "mgcv", "boot"))), 3)
    expect_equal(sum(check_installed(nse_dots(boot, DesiQuintans/boot))), 1)
    expect_equal(sum(check_installed(nse_dots(boot, mgcv, BOOT, FAKEPKG))), 2)
    expect_equal(sum(!check_installed(nse_dots(boot, mgcv, BOOT, FAKEPKG))), 2)
})


# check_attached() ------------------------------------------------------------------


test_that("check_attached() can accept arbitrary number of args", {
    skip_on_cran()
    expect_equal(length(check_attached()), length(.packages()))
    expect_equal(length(check_attached(nse_dots(boot))), 1)
    expect_equal(length(check_attached(nse_dots(DesiQuintans/boot))), 1)
    expect_equal(length(check_attached(nse_dots(mgcv, DesiQuintans/boot))), 2)
})

test_that("check_attached() returns a logical vector", {
    skip_on_cran()
    expect_type(check_attached(), "character")
    expect_type(check_attached(nse_dots(dplyr)), "logical")
    expect_type(check_attached(nse_dots(DesiQuintans/boot)), "logical")
    expect_type(check_attached(nse_dots(mgcv, DesiQuintans/boot)), "logical")
})

test_that("check_attached() with args returns correct number of attached packages", {
    skip_on_cran()
    expect_equal(sum(check_attached(nse_dots(librarian, utils, mgcv, boot))), 2)
    expect_equal(sum(check_attached(c("librarian", "utils", "mgcv", "boot"))), 2)
    expect_equal(sum(check_attached(nse_dots(librarian, DesiQuintans/librarian))), 1)
    expect_equal(sum(check_attached(nse_dots(librarian, utils, boot, UTILS, FAKEPKG))), 2)
    expect_equal(sum(!check_attached(nse_dots(librarian, utils, boot, UTILS, FAKEPKG))), 3)
})
