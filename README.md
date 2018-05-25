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

Note that this only updates the named packages, and not their dependencies. To update dependencies also, run `devtools::update_packages(c("pkg1", "pkg2", ...))`. _As usual, be careful when updating packages; your old scripts might need to be updated if packages have changed their function behaviours._

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, update_all = TRUE)
```

The `quiet = TRUE` flag can suppress many of the messages that are routinely printed by the base install/attach functions.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, quiet = TRUE)
```

`shelf` invisibly returns `devtools::session_info()`, so you can print it if you like.

``` r
sesh <- shelf(janitor, DesiQuintans/desiderata, purrr)
print(sesh)

Session info -----------------------------------------------------------------------------
 setting  value                       
 version  R version 3.4.2 (2017-09-28)
 system   x86_64, mingw32             
 ui       RStudio (1.1.453)           
 language (EN)                        
 collate  English_Australia.1252      
 tz       Australia/Sydney            
 date     2018-05-24                  

Packages ---------------------------------------------------------------------------------
 package    * version date       source        
 assertthat   0.2.0   2017-04-11 CRAN (R 3.4.2)
 base       * 3.4.2   2017-09-28 local         
 bindr        0.1.1   2018-03-13 CRAN (R 3.4.4)
 bindrcpp     0.2.2   2018-03-29 CRAN (R 3.4.4)
 compiler     3.4.2   2017-09-28 local         
 datasets   * 3.4.2   2017-09-28 local         
 desiderata * 0.2.0   2018-05-23 local         
 devtools     1.13.5  2018-02-18 CRAN (R 3.4.3)
 digest       0.6.15  2018-01-28 CRAN (R 3.4.3)
 dplyr        0.7.5   2018-05-19 CRAN (R 3.4.4)
 glue         1.2.0   2017-10-29 CRAN (R 3.4.2)
 graphics   * 3.4.2   2017-09-28 local         
 grDevices  * 3.4.2   2017-09-28 local         
 janitor    * 1.0.0   2018-03-22 CRAN (R 3.4.4)
 librarian  * 1.0.1   2018-05-24 local         
 magrittr     1.5     2014-11-22 CRAN (R 3.4.2)
 memoise      1.1.0   2017-04-21 CRAN (R 3.4.3)
 methods    * 3.4.2   2017-09-28 local         
 pillar       1.2.1   2018-02-27 CRAN (R 3.4.3)
 pkgconfig    2.0.1   2017-03-21 CRAN (R 3.4.2)
 purrr      * 0.2.4   2017-10-18 CRAN (R 3.4.4)
 R6           2.2.2   2017-06-17 CRAN (R 3.4.2)
 Rcpp         0.12.17 2018-05-18 CRAN (R 3.4.4)
 rlang        0.2.0   2018-02-20 CRAN (R 3.4.3)
 stats      * 3.4.2   2017-09-28 local         
 tibble       1.4.2   2018-01-22 CRAN (R 3.4.3)
 tidyselect   0.2.4   2018-02-26 CRAN (R 3.4.3)
 tools        3.4.2   2017-09-28 local         
 utils      * 3.4.2   2017-09-28 local         
 withr        2.1.1   2017-12-19 CRAN (R 3.4.3)
 yaml         2.1.17  2018-02-27 CRAN (R 3.4.3)
```

### `unshelf`

For unshelf, only the package names should be provided.

``` r
unshelf(dplyr, desiderata, purrr)
```

---
