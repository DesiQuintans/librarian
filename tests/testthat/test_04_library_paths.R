context("Testing library path functions")


# Temporary vars ----------------------------------------------------------

path1 <- normalizePath(file.path(tempdir(), "libtest_path1"), mustWork = FALSE, winslash = "/")
path2 <- normalizePath(file.path(tempdir(), "libtest_path2"), mustWork = FALSE, winslash = "/")
path3 <- normalizePath(file.path(tempdir(), "libtest_path3"), mustWork = FALSE, winslash = "/")



# Tests -------------------------------------------------------------------

test_that("lib_paths() lists current paths if no args are given.", {
    skip_on_cran()
    expect_identical(lib_paths(), .libPaths())
    expect_identical(lib_paths(NULL), .libPaths())
    expect_identical(lib_paths(NA), .libPaths())
    expect_identical(lib_paths(""), .libPaths())
})


test_that("'make_path = FALSE' blocks folder creation.", {
    skip_on_cran()
    expect_error(
        lib_paths(path1, make_path = FALSE, ask = FAdLSE),
        tell_user("not allowed to make path", path1)[1]
    )
    expect_error(
        lib_paths(path1, make_path = FALSE, ask = TRUE),
        tell_user("not allowed to make path", path1)[1]
    )
})


test_that("lib_paths() can create folders if allowed.", {
    skip_on_cran()
    expect_silent(lib_paths(path1, make_path = TRUE, ask = FALSE))
    expect_true(dir.exists(path1))
})


test_that("The new folder is the first element in .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths()[1], path1)
})


test_that("lib_paths() can create multiple folders if allowed.", {
    skip_on_cran()
    path_list <- c(path3, path2)
    expect_silent(lib_paths(path_list, make_path = TRUE, ask = FALSE))
    expect_false(any(!dir.exists(path_list)))  # Flip so that TRUE = failure to create.
})


test_that("When creating multiple folders, the first in the list should be the new first element in .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths()[1], path3)
})


test_that("Adding an existing folder reorders .libPaths().", {
    skip_on_cran()
    expect_identical(lib_paths(path1, make_path = FALSE, ask = FALSE)[1], path1)
})


## This test fails if it is run with devtools::test() because it doesn't count as
## a non-interactive environment. Running the test with the "Run Tests" button
## does work, however.
# test_that("'ask = TRUE' in an non-interactive session blocks folder creation.", {
#     skip_on_cran()
#     expect_error(
#         lib_paths(test_newfolder, make_path = TRUE, ask = TRUE),
#         tell_user("cannot get user feedback in a non-interactive session")[1])
# })
