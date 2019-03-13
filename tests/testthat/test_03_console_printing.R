context("Testing console-printing functions")


# Testing functions that print to the console -----------------------------

test_that("wrap_text() wraps to expected length.", {
    skip_on_cran()
    text <- "Lorem ipsum dolor sit amet, ac turpis lacus massa pulvinar egestas. Justo viverra donec tincidunt lobortis turpis ut sed tincidunt dui nam lacus. Himenaeos, vel et sodales sit. Viverra senectus donec mi donec."
    
    expect_lte(max(nchar(wrap_text(text))), 70)  # 70 is hard-coded wrap width.
})


test_that("wrap_text() assembles strings correctly.", {
    skip_on_cran()
    result <- c(
        "\n  Lorem ipsum dolor sit amet, ornare justo condimentum et sit lorem!",
        "\n  Himenaeos, vel et sodales sit. Eu nulla. Magna ullamcorper",
        "\n  nascetur placerat platea.",
        "\n",
        "\n  Eleifend semper velit sed aliquam, ut ligula non commodo."
    )
    
    expect_identical(
        wrap_text(
            "Lorem ipsum dolor sit amet, ornare justo condimentum",
            "et sit lorem! Himenaeos, vel et sodales sit.",
            "Eu nulla. Magna ullamcorper nascetur placerat platea.\n\n",
            "Eleifend semper velit sed aliquam, ut ligula non commodo."),
        result
    )
})
