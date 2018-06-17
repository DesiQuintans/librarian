context("Attaching, detaching, and reattaching built-in packages")

library(librarian)

test_that("Start with built-in packages (boot, mgcv) unattached", {
    skip_on_cran()
    expect_error(detach("package:mgcv", unload = TRUE, character.only = TRUE), "invalid 'name' argument")
    expect_error(detach("package:boot", unload = TRUE, character.only = TRUE), "invalid 'name' argument")
    expect_equal(sum(check_attached(nse_dots(mgcv, boot))), 0)
})

test_that("Try to shelf() boot and mgcv", {
    skip_on_cran()
    expect_equal(sum(shelf(boot, mgcv, boot)), 2)
    expect_equal(sum(check_attached(nse_dots(mgcv, boot, mgcv))), 2)
})

test_that("Try to unshelf() boot and mgcv", {
    skip_on_cran()
    expect_equal(sum(unshelf(boot, mgcv, mgcv)), 2)
    expect_equal(sum(check_attached(nse_dots(boot, mgcv))), 0)
})

test_that("Try to reshelf() boot and mgcv", {
    skip_on_cran()
    expect_equal(sum(reshelf(boot, boot, boot, mgcv)), 2)
    expect_equal(sum(check_attached(nse_dots(boot, mgcv))), 2)
})

test_that("Unshelf() to clean the environment", {
    skip_on_cran()
    expect_equal(sum(unshelf(boot, mgcv, mgcv)), 2)
    expect_equal(sum(check_attached(nse_dots(boot, mgcv))), 0)
})

# Note that I can't automate testing for unshelf(everything = TRUE) because, of course, it
# detaches every non-base package including testthat.