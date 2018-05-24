# Internal functions for librarian.

# Non-standard evaluation of dots with base R so that I don't need to import Rlang.
nse_dots <- function(...) {
    eval(substitute(alist(...)))
}