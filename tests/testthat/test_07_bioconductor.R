context("Installing packages from Bioconductor")

library(librarian)

suppressMessages(library(BiocManager))

.libPaths(tempdir())

# I change libpaths immediately after loading those packages because one of the tests
# below requires that Biobase is not installed to begin with (and it may be installed
# in my personal library). Using .libPaths() keeps only the default R library plus 
# any newly installed libraries.



test_that("Check zlibbioc (Bioconductor) install before Bioconductor is installed.", {
    skip_on_cran()
    expect_warning(shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE), "Are they Bioconductor")
})

# suppressWarnings() because for some reason, this raises two errors:
# cannot open URL 'https://bioconductor.org/packages/3.8/workflows/bin/windows/contrib/3.5/PACKAGES.rds': HTTP status was '404 Not Found'
# It only happens when devtools::test() runs it, it doesn't happen when I run the 
# block in my terminal.
suppressMessages(
    suppressWarnings(BiocManager::install("Biobase", ask = FALSE, update = FALSE, quiet = TRUE)))

test_that("Check zlibbioc (Bioconductor) install after Bioconductor is installed.", {
    skip_on_cran()
    expect_equal(sum(shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE)), 1)
})

test_that("Try to unshelf() zlibbioc", {
    skip_on_cran()
    expect_equal(sum(unshelf(zlibbioc, safe = FALSE)), 1)
})
