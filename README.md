# `librarian` - One-step packages from CRAN and GitHub

``` r
librarian::shelf(dplyr, DesiQuintans/desiderata, purrr)
                   ↑        ↑                      ↑
                  CRAN     GitHub                 CRAN

# All downloaded, installed, and attached.
```

`librarian` lets you quickly install, update, and attach packages from CRAN and GitHub in the same function call. It has these advantages over base R and other library management packages like `pacman`:

- **It's one function.** 
    - `shelf(janitor, DesiQuintans/desiderata)`  
      **NOT**  
      `install.packages("janitor")`  
      `devtools::install_github("DesiQuintans/desiderata")`  
      `library(janitor)`  
      `library(desiderata)`
- **It has a consistent interface.** It bothered me that `install.packages` can install many packages, but `library` can only attach one at a time. _librarian_ will install and attach them all.
- **Packages are bare names.** Miss me with those quoted names, they're such a hassle! _librarian_ uses bare names so that it's easier to maintain a large package list.

## Project participants

-   Desi Quintans (<https://twitter.com/eco_desi>)

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

## Installation

_librarian_ has been submitted to CRAN, and is waiting for approval. For now, you can install _librarian_ from GitHub with:

``` r
install.packages("devtools")

devtools::install_github("DesiQuintans/librarian")

library(librarian)

# But instead of attaching librarian, I prefer to use:

librarian::shelf(...)

librarian::unshelf(...)
```

---

## Functions included

- Use `shelf()` to attach packages to the library, installing them from CRAN/GitHub if needed
- Use `unshelf()` to detach (unload) packages from the library
- Use `reshelf()` to detach and then reattach packages

---

## Examples

### `shelf`

For CRAN packages, provide the package name as normal.  
For GitHub packages, provide the username and package name separated by `/`.

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

#> Session info -----------------------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.5.0 (2018-04-23)
#>  system   x86_64, mingw32             
#>  ui       RStudio (1.1.453)           
#>  language (EN)                        
#>  collate  English_Australia.1252      
#>  tz       Australia/Sydney            
#>  date     2018-06-03                  
#> 
#> Packages ---------------------------------------------------------------------------------
#>  package    * version    date       source                             
#>  assertthat   0.2.0      2017-04-11 CRAN (R 3.5.0)                     
#>  backports    1.1.2      2017-12-13 CRAN (R 3.5.0)                     
#>  base       * 3.5.0      2018-04-23 local                              
#>  bindr        0.1.1      2018-03-13 CRAN (R 3.5.0)                     
#>  bindrcpp     0.2.2      2018-03-29 CRAN (R 3.5.0)                     
#>  commonmark   1.5        2018-04-28 CRAN (R 3.5.0)                     
#>  compiler     3.5.0      2018-04-23 local                              
#>  datasets   * 3.5.0      2018-04-23 local                              
#>  desiderata * 0.5.0      2018-06-02 local                              
#>  devtools     1.13.5     2018-02-18 CRAN (R 3.5.0)                     
#>  digest       0.6.15     2018-01-28 CRAN (R 3.5.0)                     
#>  dplyr        0.7.5      2018-05-19 CRAN (R 3.5.0)                     
#>  evaluate     0.10.1     2017-06-24 CRAN (R 3.5.0)                     
#>  glue         1.2.0      2017-10-29 CRAN (R 3.5.0)                     
#>  graphics   * 3.5.0      2018-04-23 local                              
#>  grDevices  * 3.5.0      2018-04-23 local                              
#>  htmltools    0.3.6      2017-04-28 CRAN (R 3.5.0)                     
#>  janitor    * 1.0.0      2018-03-22 CRAN (R 3.5.0)                     
#>  knitr        1.20       2018-02-20 CRAN (R 3.5.0)                     
#>  librarian  * 1.0.2      <NA>       local                              
#>  magrittr     1.5        2014-11-22 CRAN (R 3.5.0)                     
#>  memoise      1.1.0      2017-04-21 CRAN (R 3.5.0)                     
#>  methods    * 3.5.0      2018-04-23 local                              
#>  pillar       1.2.3      2018-05-25 CRAN (R 3.5.0)                     
#>  pkgconfig    2.0.1      2017-03-21 CRAN (R 3.5.0)                     
#>  purrr      * 0.2.4      2017-10-18 CRAN (R 3.5.0)                     
#>  R6           2.2.2      2017-06-17 CRAN (R 3.5.0)                     
#>  Rcpp         0.12.17    2018-05-18 CRAN (R 3.5.0)                     
#>  rlang        0.2.0      2018-02-20 CRAN (R 3.5.0)                     
#>  rmarkdown    1.9        2018-03-01 CRAN (R 3.5.0)                     
#>  roxygen2     6.0.1      2017-02-06 CRAN (R 3.5.0)                     
#>  rprojroot    1.3-2      2018-01-03 CRAN (R 3.5.0)                     
#>  rstudioapi   0.7.0-9000 2018-05-30 Github (rstudio/rstudioapi@12870f8)
#>  stats      * 3.5.0      2018-04-23 local                              
#>  stringi      1.1.7      2018-03-12 CRAN (R 3.5.0)                     
#>  stringr      1.3.1      2018-05-10 CRAN (R 3.5.0)                     
#>  tibble       1.4.2      2018-01-22 CRAN (R 3.5.0)                     
#>  tidyselect   0.2.4      2018-02-26 CRAN (R 3.5.0)                     
#>  tools        3.5.0      2018-04-23 local                              
#>  utils      * 3.5.0      2018-04-23 local                              
#>  withr        2.1.2      2018-03-15 CRAN (R 3.5.0)                     
#>  xml2         1.2.0      2018-01-24 CRAN (R 3.5.0)                     
#>  yaml         2.1.19     2018-05-01 CRAN (R 3.5.0)    
```

### `unshelf`

When unattaching GitHub packages with `unshelf()`, you can provide the package names only, or you can provide the full username/package identifier as you did with `shelf()`. 

If you want to refresh a package by detaching and then reattaching it, use `reshelf()`.

``` r
# These are the same:

unshelf(janitor, desiderata, purrr)
unshelf(janitor, DesiQuintans/desiderata, purrr)

# You can quickly unload-reload packages by just changing 'shelf' to 'unshelf'.

  shelf(janitor, DesiQuintans/desiderata, purrr)
unshelf(janitor, DesiQuintans/desiderata, purrr)
```

### `reshelf`

If you maintain a personal package, you'll often find yourself adding a function to it and rebuilding it in one instance of RStudio, and then reloading the new build in a different RStudio instance that contains your actual work. `reshelf()` does this in one line.

``` r
reshelf(DesiQuintans/desiderata)

# is identical to

unshelf(DesiQuintans/desiderata)
  shelf(DesiQuintans/desiderata)
```
