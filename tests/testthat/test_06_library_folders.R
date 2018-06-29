context("Manipulating library folders with library_folder()")

library(librarian)

test_newfolder <- normalizePath(file.path(tempdir(), "newfolder"), mustWork = FALSE, winslash = "/")
test_otherdir <- normalizePath(file.path(tempdir(), "otherdir"), mustWork = FALSE, winslash = "/")

test_that("lib_paths() should return .libPaths() if 'path' arg is omitted.", {
    expect_identical(lib_paths(), .libPaths())
})

test_that("'make_path = FALSE' should not allow folder creation.", {
    skip_on_cran()
    expect_error(lib_paths(test_newfolder, make_path = FALSE, ask = FALSE))
})

test_that("'ask = FALSE' arg should allow silent creation of 'newfolder'.", {
    skip_on_cran()
    expect_silent(lib_paths(test_newfolder, make_path = TRUE, ask = FALSE))
    expect_true(dir.exists(test_newfolder))
})

test_that("'newfolder' should be the first element in .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths()[1], test_newfolder)
})

test_that("Try creating another folder ('otherdir').", {
    skip_on_cran()
    expect_silent(lib_paths(test_otherdir, make_path = TRUE, ask = FALSE))
    expect_true(dir.exists(test_otherdir))
})

test_that("'otherdir' should now be the first element in .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths()[1], test_otherdir)
})

test_that("'newfolder' should now be the second element in .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths()[2], test_newfolder)
})

unlink(c(test_newfolder, test_otherdir), recursive = TRUE)
rm(test_newfolder, test_otherdir)