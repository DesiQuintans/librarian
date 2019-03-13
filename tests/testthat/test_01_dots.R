context("Testing functions that process '...'")


# Test dots-validating functions ------------------------------------------

test_that("dots_is_empty() returns booleans.", {
    skip_on_cran()
    expect_true(dots_is_empty())
    expect_false(dots_is_empty(notempty))
})


test_that("dots1_is_pkglist() can detect character vector in ..1.", {
    skip_on_cran()
    expect_false(dots1_is_pkglist())
    expect_false(dots1_is_pkglist(hello, hey, hi))
    expect_false(dots1_is_pkglist("hello", hey, hi))
    expect_false(dots1_is_pkglist("hello", "hey", "hi"))
    expect_false(dots1_is_pkglist(c(hello, hey), "hi"))
    expect_true( dots1_is_pkglist(c("hello", "hey"), "hi"))
    
    vec <- c("list with one item")
    expect_true( dots1_is_pkglist(vec))
    expect_false(dots1_is_pkglist(vec, other_item))
})


# Test nse_dots() ---------------------------------------------------------

test_that("nse_dots() returns character(0) if dots is empty.", {
    skip_on_cran()
    expect_identical(nse_dots(), character(0))
})


test_that("nse_dots() can handle an arbitrary number of args.", {
    skip_on_cran()
    expect_length(nse_dots(hello), 1)
    expect_length(nse_dots(is, it), 2)
    expect_length(nse_dots(me, youre, looking, foooor), 4)
})


test_that("nse_dots() uses only ..1 if it is a char vector with length > 1.", {
    skip_on_cran()
    expect_identical(
        nse_dots(c("dplyr", "tidyr"), "otherpkg"), 
        c("dplyr", "tidyr"))
})


test_that("nse_dots() does not modify valid strings that are passed to it.", {
    skip_on_cran()
    test_vec <- c("username/my1strepo", "username6/my1strepo", "user-name6/my1strepo", 
                  "user_name6/my1strepo", "user.name6/my1strepo", "username6/my.1st.repo", 
                  "username6/my.1st-repo", "username/my_1st_repo@v1.0.0", 
                  "username/my_1st_repo#123", "username6/my-1st_repo")
    
    expect_identical(
        nse_dots("username/my1strepo", "username6/my1strepo", "user-name6/my1strepo", 
                 "user_name6/my1strepo", "user.name6/my1strepo", "username6/my.1st.repo", 
                 "username6/my.1st-repo", "username/my_1st_repo@v1.0.0", 
                 "username/my_1st_repo#123", "username6/my-1st_repo", 
                 keep_user = TRUE), 
        test_vec)
})


test_that("nse_dots() converts valid names to strings without modifying them.", {
    skip_on_cran()
    test_vec <- c("username/my1strepo", "username6/my1strepo", "user-name6/my1strepo", 
                    "user_name6/my1strepo", "user.name6/my1strepo", "username6/my.1st.repo", 
                    "username6/my.1st-repo", "username/my_1st_repo@v1.0.0")
    
    expect_identical(
        nse_dots(username/my1strepo, username6/my1strepo, user-name6/my1strepo, 
                 user_name6/my1strepo, user.name6/my1strepo, username6/my.1st.repo, 
                 username6/my.1st-repo, username/my_1st_repo@v1.0.0,
                 keep_user = TRUE), 
        test_vec)
})


test_that("'keep_user' arg in nse_dots() can remove GitHub usernames.", {
    skip_on_cran()
    expect_identical(nse_dots("user/pkg", user2/pkg2, pkgname, keep_user = TRUE),
                     c("user/pkg", "user2/pkg2", "pkgname"))
    
    expect_identical(nse_dots("user/pkg", user2/pkg2, pkgname, keep_user = FALSE),
                     c("pkg", "pkg2", "pkgname"))
})


test_that("nse_dots() can process a mix of names and strings.", {
    skip_on_cran()
    test_vec <- c("thisis/astring", "thisis/aname", "alsoastring", "alsoaname")
    
    expect_identical(
        nse_dots("thisis/astring", thisis/aname, "alsoastring", alsoaname, keep_user = TRUE),
        test_vec)
})


test_that("nse_dots() removes duplicate entries from dots.", {
    skip_on_cran()
    expect_identical(
        nse_dots(user/pkg, user2/pkg, diff_pkg, keep_user = TRUE),
        c("user/pkg", "user2/pkg", "diff_pkg"))
    
    expect_identical(
        nse_dots(user/pkg, user2/pkg, diff_pkg, keep_user = FALSE),
        c("pkg", "diff_pkg"))
})

test_that("nse_dots() removes empty entries from dots.", {
    skip_on_cran()
    expect_identical(
        nse_dots(, tidyr, "DesiQuintans/desiderata"),
        c("tidyr", "desiderata"))
    
    expect_identical(
        nse_dots("", tidyr, "DesiQuintans/desiderata"),
        c("tidyr", "desiderata"))
})



