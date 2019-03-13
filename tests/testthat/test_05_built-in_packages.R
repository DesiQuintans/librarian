context("Testing shelf() and unshelf() with local packages")

library(librarian)

# 'datasets' package is used because trying to use a non-default built-in package (boot,
# mgcv) in R CMD CHECK returns an error about those packages not existing. Seems like R
# CMD CHECK doesn't actually have a library. So that's why I use a package that I know is
# already loaded at startup.

test_that("'datasets' is attached by default, so unattach it.", {
    skip_on_cran()
    expect_null(detach("package:datasets", unload = TRUE, character.only = TRUE))
    expect_identical(
        check_attached(datasets),
        c(datasets = FALSE))
})

test_that("Try to shelf() 'datasets'", {
    skip_on_cran()
    expect_identical(
        shelf(datasets, cran_repo = "https://cran.r-project.org"),
        c(datasets = TRUE))
})

test_that("Try to unshelf() 'datasets'", {
    skip_on_cran()
    # Has to be safe = FALSE or else R CMD CHECK is unhappy.
    expect_identical(
        unshelf(datasets, safe = FALSE),
        c(datasets = TRUE))
})

test_that("Try to reshelf() 'datasets'", {
    skip_on_cran()
    expect_identical(
        reshelf(datasets),
        c(datasets = TRUE))
})

test_that("'also_depends = FALSE' only detaches the selected package.", {
    skip_on_cran()
    expect_identical(
        shelf(tidyverse),
        c(tidyverse = TRUE))
    
    expect_identical(
        unshelf(tidyverse, also_depends = FALSE),
        c(tidyverse = TRUE))
})


test_that("'safe = TRUE' stops detaching of still-needed dependencies.", {
    skip_on_cran()
    
    expect_identical(
        shelf(tidyverse),
        c(tidyverse = TRUE))
    
    expect_silent(
        expect_identical(
            unshelf(tidyverse, also_depends = TRUE, safe = TRUE, quiet = TRUE),
            c(tidyverse = TRUE, forcats = TRUE, ggplot2 = TRUE, readr = TRUE, stringr = TRUE, tidyr = TRUE)
        )
    )
    
    expect_identical(
        shelf(tidyverse),
        c(tidyverse = TRUE))
    
    expect_message(
        expect_identical(
            unshelf(tidyverse, also_depends = TRUE, safe = TRUE, quiet = FALSE),
            c(tidyverse = TRUE, forcats = TRUE, ggplot2 = TRUE, readr = TRUE, stringr = TRUE, tidyr = TRUE)
        ),
        tell_user("some packages still being used", "")[1]
    )
})

test_that("'safe = FALSE' allows still-needed dependencies to be detached.", {
    skip_on_cran()
    
    expect_identical(
        shelf(tidyverse),
        c(tidyverse = TRUE))
    
    expect_silent(
        expect_identical(
            unshelf(tidyverse, also_depends = TRUE, safe = FALSE, quiet = FALSE),
            c(tidyverse = TRUE, dplyr = TRUE, forcats = TRUE, ggplot2 = TRUE, 
              purrr = TRUE, readr = TRUE, stringr = TRUE, tibble = TRUE, tidyr = TRUE)
        )
    )
})
