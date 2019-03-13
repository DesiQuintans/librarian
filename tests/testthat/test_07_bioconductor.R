context("Installing packages from Bioconductor")

# Explicitly attach praise because it's needed at the end of testing so that I
# can feel good :3
shelf(praise)

# Changing lib dirs with .libPaths() keeps only the default R library plus
# tempdir(). I need to change library locations because the Bioconductor
# packages may already be installed on my personal paths.
.libPaths(tempdir())


test_that("Bioconductor packages should not be installed if Biobase is not installed.", {
    skip_on_cran()
    
    expect_warning(
        shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE), 
        "Are they Bioconductor")
})


test_that("BiocManager and Biobase can be installed.", {
    skip_on_cran()
    
    expect_identical(
        shhh(shelf(BiocManager, quiet = TRUE)),
        c(BiocManager = TRUE)
    )
    
    expect_error(
        shhh(BiocManager::install("Biobase", ask = FALSE, update = FALSE, quiet = TRUE)),
        regexp = NA
    )
})


test_that("Bioconductor packages can be installed when Biobase is installed.", {
    skip_on_cran()
    
    expect_identical(
        shhh(shelf(zlibbioc, lib = tempdir(), quiet = TRUE, update_all = TRUE)),
        c(zlibbioc = TRUE)
    )
})

test_that("Try to unshelf() zlibbioc", {
    skip_on_cran()
    
    expect_identical(
        unshelf(zlibbioc, safe = FALSE),
        c(zlibbioc = TRUE))
})
