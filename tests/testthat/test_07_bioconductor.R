context("Installing packages from Bioconductor")

library(librarian)
.libPaths(tempdir())  
# Can't use librarian::lib_paths() because my personal .Rprofile sets a default library
# path whenever R starts a new session, and Bioconductor is installed in that path. 
# Because Biobase is already there, the 'install zlibbioc before Bioconductor is installed'
# test fails. Using .libPaths() keeps only the default R library plus any new library.

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
