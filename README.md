# librarian

## Project participants

-   Desi Quintans (<https://twitter.com/eco_desi>)

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

## What is `librarian`?

`librarian` lets you quickly install, update, and attach packages from CRAN and GitHub in the same function call. It has these advantages over base R:

- **It's one function.** No `install.packages("janitor")` and then `library(janitor)`, just `shelf(janitor)`.
- **A consistent interface.** It bothered me that `install.packages` can install many packages, but `library` can only attach one at a time. _librarian_ will install and attach them all.
- **Packages are bare names.** Miss me with those quoted names, they're such a hassle! _librarian_ uses bare names for convenience.

(PS. I can't believe that 'librarian' is an available name! That's what I'll submit to CRAN with.)

## Installation

You can install librarian from github with:

``` r
install.packages("devtools")

devtools::install_github("DesiQuintans/librarian")

library(librarian)
```

---

## Functions included

- Use `shelf` to attach packages to the library, installing them from CRAN/GitHub if needed
- Use `unshelf` to detach (unload) packages from the library

---

## Examples

### `shelf`

For CRAN packages, provide the package name as normal. For GitHub packages, provide the username and package name separated by `/`.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr)
```

To force all of the named packages to re-download and re-install, use `update_all = TRUE`.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, update_all = TRUE)
```

The `quiet = TRUE` flag can suppress many of the messages that are routinely printed by the base install/attach functions.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, quiet = TRUE)
```

### `unshelf`

For unshelf, only the package names should be provided.

``` r
unshelf(dplyr, desiderata, purrr)
```
