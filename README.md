# Discontinued

Hello, `librarian` is discontinued as of 2024-12-28, and no further maintenance or development will be done to it. I have made this decision because my thoughts regarding package installation and loading have changed in the 6.5 years since I started this package. Namely:

1. **A large block of `library()` is okay, actually.** It is easy to copy, paste, delete, and remove entire packages when each package is on a new line.
2. **Installation of packages is better handled by [`pak`](https://pak.r-lib.org/) than anything else.** Like `librarian`, the `pak` package automates the installation of multiple packages at a time from CRAN, Bioconductor, GitHub, and other sources. _Unlike_ `librarian`, `pak` does it a) in parallel, b) without re-installing the package when no changes have been made, c) with fewer collisions with packages that are already attached to the session, and d) with support for [`renv`](https://rstudio.github.io/renv/index.html).

---------------------------------------------------------------------



# `librarian` - One-step packages from CRAN, GitHub, and Bioconductor

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/librarian)](https://cran.r-project.org/package=librarian)
[![Download Stats](http://cranlogs.r-pkg.org/badges/librarian)](https://cran.r-project.org/package=librarian)

``` r
librarian::shelf(dplyr, DesiQuintans/desiderata, phyloseq)
                   ↑        ↑                      ↑
                  CRAN     GitHub                 Bioconductor

# All downloaded, installed, and attached.
```

`librarian` lets you quickly install, update, and attach packages from CRAN, GitHub, and Bioconductor in one function call. It has these advantages over base R and other library management packages like `pacman`:

### Advantage 1: _Librarian_ installs and attaches in one function call

    shelf(dplyr, DesiQuintans/desiderata, phyloseq)
    
Is a lot nicer than:

    install.packages("dplyr")
    remotes::install_github("DesiQuintans/desiderata")
    biocLite("phyloseq")
    library(dplyr)
    library(desiderata)
    library(phyloseq)

### Advantage 2: _Librarian_ has a consistent interface

It bothered me that `install.packages()` can install many packages, but `library()` can only attach one at a time. It bothered me that `install.packages()` needs a character vector, but `library()` can accept either a character vector or a bare name.

Core _librarian_ functions (`shelf`, `reshelf`, `unshelf`) always accept a list of one or more bare names.

### Advantage 3: _Librarian_'s package lists are easy to read and easy to maintain

Using bare names instead of strings frees you from typing quotes all the time. Having all of your packages in one `shelf()` call means that the reader can get an overview of your package dependencies at a glance.

> We don’t want to clutter up the tops of our modules with 80 lines of imports. 
> Rather we want the imports to be a concise statement about which packages we 
> collaborate with.
> 
> --- Robert C. Martin, _Clean Code_



## Installation

You can install _librarian_ from CRAN or from GitHub. The GitHub version is under constant development, but it has more features and it is stable for use (it's the one I personally use, after all).

_Major features that are currently **MISSING** from the CRAN release:_ No new features are missing, but some speed improvements and bug fixes are.

``` r
# From CRAN:

install.packages("librarian")

# From GitHub:

install.packages("remotes")
remotes::install_github("DesiQuintans/librarian")
```

Once it's installed, you can get librarian to automatically load at the start of every R session:

``` r
librarian::lib_startup(librarian, global = TRUE)
```

And you can also specify a library folder to install new packages into by default:

``` r
librarian::lib_startup(librarian, lib = "C:/Dropbox/My R Library", global = TRUE)
```

Or if you don't want to do that, you can attach it with `library(librarian)` or access the functions directly with `::` notation:

``` r
librarian::shelf(...)
librarian::unshelf(...)
librarian::reshelf(...)
```

## Quick tour of _librarian_

The metaphor behind function names is one of a very large public library that has more books than public shelf space. The librarian needs to decide what books are useful enough to warrant display, and which books should stay in storage for now. You take packages out of storage and put them on the `shelf()` (the search path) when you need them, and then `unshelf()` them when you don't need them.

More in-depth documentation for each function is in the [Examples section](#examples) below.

| Function        | Example                                  | Description                                                                                                                                                    |
| ------------:   | :--------------------------------------- | :---------------------------------------------------------------------------------                                                                             |
| `shelf()`       | `shelf(cowsay, DesiQuintans/desiderata)` | Attach packages to the search path, installing them from CRAN, Bioconductor, or GitHub if needed. They will be installed to the first folder in `lib_paths()`. |
| `unshelf()`     | `unshelf(cowsay, desiderata)`            | Detach packages from the search path. You can also detach their dependencies.                                                                                  |
| `reshelf()`     | `reshelf(desiderata)`                    | Detach and then reattach packages, helpful for refreshing a personal package.                                                                                  |
| `stock()`   | `stock(cowsay, DesiQuintans/desiderata)`         | Install packages without attaching them.                                        |
| `lib_paths()`   | `lib_paths("C:/new_lib_folder")`         | View and edit the folders where R will install and search for packages.                                                                                        |
| `lib_startup()` | `lib_startup(librarian, forcats)`        | Automatically attach libraries and packages at the start of every R session.                                                                                   |
| `browse_cran()` | `browse_cran("linear regression")`       | Discover CRAN packages by keyword search or regular expression.                                                                                                |

## Examples

### shelf

`shelf()` attaches packages to the search path, first installing them from CRAN, GitHub, or Bioconductor if needed.

The order of package names is the order they will be attached to the current R session. 

For CRAN packages, provide the package name as normal.
For Bioconductor packages, provide the package name as normal **and make sure that Bioconductor's `Biobase` package is installed.**
For GitHub packages, provide the username and package name separated by `/`.

``` r
shelf(cowsay, DesiQuintans/desiderata, zlibbioc)
```

The default installation folder is always the first folder in `lib_paths()`. To change the installation folder, set the `lib` argument.

If `lib` doesn't already exist, `shelf()` can create it for you. By default, you will be asked for permission before the folder is created. To create the folder silently, set `ask = FALSE`.

``` r
shelf(cowsay, DesiQuintans/desiderata, lib = "C:/new_lib_folder", ask = TRUE)
```

You can download from a specific CRAN mirror by setting `cran_repo`. The default value of `cran_repo` is the value set in `getOption("repos")`. You can set this in RStudio using _Options > Packages > Default CRAN Mirror_. If you are not in RStudio this option may not be correctly set. In all cases where `cran_repo` is not a valid URL, it defaults to `https://cran.r-project.org`.

You can also set a Bioconductor repo using the `bioc_repo` argument, although it perhaps better to use the built-in `utils::chooseBioCmirror()` function.

``` r
shelf(dplyr, cran_repo = "https://cran.csiro.au/")
```

To force all of the named packages to re-download and re-install, use `update_all = TRUE`. 

Note that this only updates the named packages and not their dependencies. To update dependencies also, run `devtools::update_packages(c("pkg1", "pkg2", ...))`. _As usual, be careful when updating packages; your old scripts might need to be updated if packages have changed their function behaviours._

If you specify a new `lib` and use the argument `update_all = TRUE` to force an already-installed package to reinstall, a new copy of that package will be made in `lib` and then loaded from there. This means that you can potentially have several copies of the same package across many folders on your machine, each a different version. This allows you to maintain a different library folder for different projects, so that updated packages in Project B will not affect the package versions you rely on for Project A.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, update_all = TRUE)
```

The `quiet = TRUE` flag can suppress many of the messages that are routinely printed by the base install/attach functions.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr, quiet = TRUE)
```

`shelf` invisibly returns a named vector of the packages that were requested and whether they are now attached.

``` r
shelf(janitor, DesiQuintans/desiderata, purrr)
print(.Last.value)

#>   janitor      purrr desiderata 
#>      TRUE       TRUE       TRUE
```

---

### unshelf

When detaching GitHub packages with `unshelf()`, you can provide the package names only, or you can provide the full username/package identifier as you did with `shelf()`. 

`unshelf()` invisibly returns a named vector of the packages that were requested and whether they are now detached.

If you want to refresh a package by detaching and then reattaching it, use `reshelf()`.

``` r
# These are the same:

unshelf(janitor, desiderata, purrr)
unshelf(janitor, DesiQuintans/desiderata, purrr)
```

You can use the `everything = TRUE` argument to detach all packages except for the default ones that load when R starts up. 

``` r
unshelf(everything = TRUE)
print(.Last.value)

#> librarian testthat
#> TRUE      TRUE
```

The `also_depends = TRUE` argument will also detach the dependencies of the packages you've requested in `...`. If `safe = TRUE`, packages won't be detached if they're still needed by other packages that aren't in `...`.

``` r
shelf(tidyverse, janitor)  

librarian:::check_attached()

#> [1] "janitor"   "forcats"   "stringr"   "dplyr"     "purrr"     "readr"     "tidyr"     "tibble"   
#> [9] "ggplot2"   "tidyverse" "librarian" "stats"     "graphics"  "grDevices" "utils"     "datasets" 
#> [17] "methods"   "base"     

# Tidyverse loads dplyr and purrr, which Janitor depends on. The safe = TRUE argument 
# will stop them from being detached even though Tidyverse is being detached 
# with also_depends = TRUE.

unshelf(tidyverse, also_depends = TRUE, safe = TRUE, quiet = FALSE)

#> Some packages were not detached because other packages still need them:
#>     dplyr  purrr  tidyr
#> To force them to detach, use the 'safe = FALSE' argument.

librarian:::check_attached()

#> [1] "janitor"   "dplyr"     "purrr"     "tidyr"     "librarian" "stats"     "graphics"  "grDevices"
#> [9] "utils"     "datasets"  "methods"   "base"     

unshelf(tidyverse, also_depends = TRUE, safe = FALSE, quiet = FALSE)

librarian:::check_attached()

#> [1] "janitor"   "librarian" "stats"     "graphics"  "grDevices" "utils"     "datasets"  "methods"  
#> [9] "base"
```

In the example above, setting `quiet = TRUE` will suppress the "some packages were not detached" message.

---

### reshelf

`reshelf()` detaches and then reattaches packages. This is useful when you have a personal package, because you'll often find yourself adding a function to it and rebuilding it in one instance of RStudio, and then reloading the new build in a different RStudio instance that contains your actual work. Its return value is identical to `shelf()`.

``` r
reshelf(DesiQuintans/desiderata)

# is identical to

unshelf(DesiQuintans/desiderata, safe = FALSE, warn = FALSE))
  shelf(DesiQuintans/desiderata)
```

---

### stock

`stock()` installs packages _without_ attaching them. This is useful if you only want to ensure that a package is installed before you refer to it by namespace.

``` r
stock(DesiQuintans/desiderata)

desiderata::Mode(...)
```

---

### lib_paths

`lib_paths()` lets you view and edit the list of folders that R will look inside when trying to find a package (the package search path). You can also add an existing folder, create and add a new folder, or shuffle a folder to the front of the list so that it is used as the default installation location for new packages in the current session.

When called without arguments, returns a vector of the folders where R will search for and install packages.

``` r
lib_paths()

#> [1] "D:/R/R-3.5.0/library"
```

You can offer a path to a folder to add it to the package search path. If this folder doesn't exist, `lib_paths()` can create it if you set `make_path = TRUE`.

``` r
lib_paths(file.path(tempdir(), "newlibraryfolder"), make_path = TRUE)

   #> The requested library folder does not exist:
   #> 
   #> C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder
   #> 
   #> Create it?
   #> 
   #> y/N/c

# y

#> [1] "C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder"
#> [2] "D:/R/R-3.5.0/library"
```

If you don't want to be prompted, you can set `ask = FALSE` to allow the folder to be created silently.

``` r
lib_paths(file.path(tempdir(), "another_folder"), make_path = TRUE, ask = FALSE)

#> [1] "C:/Users/.../Temp/Rtmp0Qbvgo/another_folder"
#> [2] "C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder"
#> [3] "D:/R/R-3.5.0/library"
```

Notice that folders are always prepended to the front of the search path. Adding an existing folder moves it to the front.

``` r
lib_paths(file.path(tempdir(), "newlibraryfolder"))

#> [1] "C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder"
#> [2] "C:/Users/.../Temp/Rtmp0Qbvgo/another_folder"
#> [3] "D:/R/R-3.5.0/library"
```

---

### lib_startup

`lib_startup()` tells R to attach packages and library folders automatically at the start of every session.

**Note that this messes with the reproducibility of your scripts**; other people won't have your .Rprofile script, so they won't know what packages are being attached behind-the-scenes. This is really just a convenience for you. You should still explicitly load the packages that you need in your analysis scripts.

You can provide a list of packages that you would like to start with every R session. `lib_startup()` will add your current library folders as well as your current library paths (by default) to a file called `.Rprofile`. 

If `global = TRUE`, then `.Rprofile` will be created in your home folder and will be applied to every session. If `global = FALSE`, then `.Rprofile` will be created in the project folder (i.e. the current working directory) _and the global `.Rprofile` will be ignored for this project_.

``` r
lib_startup(librarian, magrittr, global = TRUE)

#> Added library paths and startup packages to:
#>   C:/Users/.../Documents/.Rprofile
#> 
#> Library paths:
#>   'D:/Dropbox/Apps/R library', 'D:/R/R-3.5.1/library'
#> 
#> Startup packages:
#>   'datasets', 'utils', 'grDevices', 'graphics', 'stats', 'methods', 'librarian', 'magrittr'
```

Notice that your packages are loaded after R's default packages. If the environmental variable `R_DEFAULT_PACKAGES` is set then it will use those packages, otherwise it will use R's own list of defaults: _datasets, utils, grDevices, graphics, stats,_ and _methods_. 

If you want to load only the default packages, just run `lib_startup()` without specifying any packages.

``` r
lib_startup()

#> Added library paths and startup packages to:
#>   C:/Users/.../Documents/.Rprofile
#> 
#> Library paths:
#>   'D:/Dropbox/Apps/R library', 'D:/R/R-3.5.1/library'
#> 
#> Startup packages:
#>   'datasets', 'utils', 'grDevices', 'graphics', 'stats', 'methods'
```

---

### browse_cran

`browse_cran()` lets you discover CRAN packages from your terminal. The first time you run `browse_cran()` in a session, it will take about 6–12 seconds to download and cache CRAN data. This only happens once per session; subsequent calls will use the cached copy.

    browse_cran("colorbrewer")
    
    #> RColorBrewer 
    #>     Provides color schemes for maps (and other graphics) designed by Cynthia 
    #>     Brewer as described at http://colorbrewer2.org 
    #> 
    #> Redmonder 
    #>     Provide color schemes for maps (and other graphics) based on the color 
    #>     palettes of several Microsoft(r) products. Forked from 'RColorBrewer' 
    #>     v1.1-2.
    
You can search with keywords or with regular expressions.

    browse_cran("zero-inflat.*?abund", fuzzy = FALSE)
    
    #> hurdlr 
    #>     When considering count data, it is often the case that many more zero 
    #>     counts than would be expected of some given distribution are observed. It 
    #>     is well established that data such as this can be reliab[...] 

You can also do **fuzzy orderless matching**, it's a little slow but it will get you results on tricky searches:

    browse_cran("network.*?api.*?twitter", fuzzy = FALSE)

    #> No CRAN packages matched query: 'network.*?api.*?twitter'.

    browse_cran("network twitter api", fuzzy = TRUE)

    #> RKlout 
    #>     An interface of R to Klout API v2. It fetches Klout Score for a Twitter 
    #>     Username/handle in real time. Klout is a website and mobile app that uses 
    #>     social media analytics to rank its users according to [...] 



---

## Project participants

-   Desi Quintans (<https://twitter.com/eco_desi>)

### With contributions from:

-   Miles Smith (<https://github.com/milescsmith/>)

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/DesiQuintans/librarian/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
