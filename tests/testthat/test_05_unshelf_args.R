context("unshelf() argument functionality")

library(librarian)

# also_depends, safe, quiet

test_that("'also_depends' should operate on ... and their dependencies.", {
    skip_on_cran()
    expect_equal(sum(shelf(tidyverse)), 1)
    expect_equal(sum(unshelf(tidyverse, also_depends = FALSE, safe = FALSE, quiet = TRUE)), 1)
    expect_gt(length(unshelf(tidyverse, also_depends = TRUE, safe = FALSE, quiet = TRUE)), 1)
})

test_that("'quiet' argument should suppress failed-detach message created by 'safe'.", {
    skip_on_cran()
    expect_equal(sum(shelf(dplyr, janitor)), 2)
    expect_message(unshelf(dplyr, safe = TRUE, quiet = FALSE))
    expect_silent(unshelf(dplyr, safe = TRUE, quiet = TRUE))
    expect_silent(unshelf(dplyr, safe = FALSE, quiet = FALSE))
})