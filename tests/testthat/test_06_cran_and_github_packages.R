context("Installing packages from CRAN and GitHub")



test_that("Install fortunes (CRAN) and emptyRpackage (GitHub)", {
    skip_on_cran()
    
    expect_identical(
        shhh(shelf(fortunes, lib = tempdir(), quiet = TRUE, update_all = TRUE)),
        c(fortunes = TRUE)
    )
    
    expect_type(fortunes::fortune(), "list")
    
    expect_identical(
        shhh(shelf(DesiQuintans/emptyRpackage, lib = tempdir(), quiet = TRUE, update_all = TRUE)),
        c(emptyRpackage = TRUE))
    
    expect_identical(
        emptyRpackage::hello_emptyR(), 
        "emptyRpackage is installed!")
})

test_that("Check 'cran_repo' error catching and 'quiet' compliance.", {
    skip_on_cran()
    
    expect_warning(shelf(fortunes, lib = tempdir(), cran_repo = "this is not a URL"))
    
    expect_silent(shelf(fortunes, lib = tempdir(), quiet = TRUE, cran_repo = "this is not a URL"))
})

test_that("Try to unshelf() fortunes and emptyRpackage", {
    skip_on_cran()
    
    expect_identical(
        unshelf(fortunes, DesiQuintans/emptyRpackage, safe = FALSE),
        c(fortunes = TRUE, emptyRpackage = TRUE)
    )
})

