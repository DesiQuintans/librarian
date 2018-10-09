context("Installing packages from Bioconductor")

library(librarian)
librarian::lib_paths(tempdir())

if (exists("biocLite") == FALSE) {
    suppressWarnings(
        suppressMessages(
            source("https://bioconductor.org/biocLite.R", echo = FALSE, verbose = FALSE)
        )
    )
}

test_that("Check zlibbioc (Bioconductor) install before Bioconductor is installed.", {
    skip_on_cran()
    expect_warning(shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE), "Are they Bioconductor")
})

biocLite("Biobase", suppressUpdates = TRUE, lib = tempdir())

test_that("Check zlibbioc (Bioconductor) install after Bioconductor is installed.", {
    skip_on_cran()
    expect_equal(sum(shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE)), 1)
})

test_that("Try to unshelf() zlibbioc", {
    skip_on_cran()
    expect_equal(sum(unshelf(zlibbioc, safe = FALSE)), 1)
})
