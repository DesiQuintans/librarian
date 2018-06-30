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
- **It has a consistent interface.**  
It bothered me that `install.packages` can install many packages, but `library` can only attach one at a time. _librarian_ will install and attach them all.
- **Packages are bare names.**  
Miss me with those quoted names, they're such a hassle! _librarian_ uses bare names so that it's easier to maintain a package list. If you're trying a different analysis and you need a new package, just add it to the list and it will download and attach with a few keystrokes.

When I was coming up with a naming scheme for this package and its functions, I had this idea that very big libraries (or indeed, networks of libraries within your city/state/country) can have so many books that they can't all fit on the public shelves. Librarians need to decide what is useful enough to warrant shelf space, and what can just stay in storage for now. So _librarian_ takes packages out of storage and puts them on the `shelf()` (the search path), and then lets you `unshelf()` them when they're not needed anymore.

## Installation

_librarian_ has been submitted to CRAN, and is waiting for approval. For now, you can install _librarian_ from GitHub with:

``` r
install.packages("devtools")

devtools::install_github("DesiQuintans/librarian")

library(librarian)

# But instead of attaching librarian, I prefer to use:

librarian::shelf(...)

librarian::unshelf(...)

librarian::reshelf(...)
```

## Selecting a library location

If you want to define a custom location for your library:

``` r
.libPaths("Path/to/library/folder")
```

You can apply this to every R session by adding it to the `.First()` function in your site profile (`R\R-3.x.x\etc\Rprofile.site`):

``` r
.First <- function(){
    .libPaths("Path/to/library/folder")
}
```
If you install R outside the system's user folders, then you can edit your site profile without needing administrator rights, which is very handy. 

If you edit the site profile for every version of R you have installed, you can install a package once and then access it in all of your R versions (assuming the R version meets the packages' requirements, of course). I have my library on Dropbox so that I can use them at home, at work, and on my laptop and always know that it's the same version.

## Project participants

-   Desi Quintans (<https://twitter.com/eco_desi>)

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

---

## Functions included

|      Function | Example                                  | Description                                                                        |
| ------------: | :--------------------------------------- | :--------------------------------------------------------------------------------- |
|     `shelf()` | `shelf(cowsay, DesiQuintans/desiderata)` | Attach packages to the search path, installing them from CRAN or GitHub if needed. |
|   `unshelf()` | `unshelf(cowsay, desiderata)`            | Detach packages from the search path.                                              |
|   `reshelf()` | `reshelf(desiderata)`                    | Detach and then reattach packages, helpful for refreshing a personal package.      |
| `lib_paths()` | `lib_paths("C:/new_lib_folder")`         | View and edit the folders where R will install and search for packages.            |

---

## Examples

### `shelf`

`shelf()` attaches packages to the search path, first installing them from CRAN or GitHub if needed.

For CRAN packages, provide the package name as normal.
For GitHub packages, provide the username and package name separated by `/`.

``` r
shelf(cowsay, DesiQuintans/desiderata)
```

The default installation folder is always the first folder in `lib_paths()`. To change the installation folder, set the `lib` argument.

If `lib` doesn't already exist, `shelf()` can create it for you. By default, you will be asked for permission before the folder is created. To create the folder silently, set `ask = FALSE`.

``` r
shelf(cowsay, DesiQuintans/desiderata, lib = "C:/new_lib_folder", ask = TRUE)
```

You can download from a specific CRAN mirror by setting `cran_repo`. The default value of `cran_repo` is the value set in `getOption("repos")`. You can set this in RStudio using _Options > Packages > Default CRAN Mirror_. If you are not in RStudio this option may not be correctly set. In all cases where `cran_repo` is not a valid URL, it defaults to `https://cran.r-project.org`.

``` r
shelf(dplyr, cran_repo = "https://cran.csiro.au/")
```

To force all of the named packages to re-download and re-install, use `update_all = TRUE`. 

Note that this only updates the named packages and not their dependencies. To update dependencies also, run `devtools::update_packages(c("pkg1", "pkg2", ...))`. _As usual, be careful when updating packages; your old scripts might need to be updated if packages have changed their function behaviours._

If you specify a new `lib` and use the argument `update_all = TRUE` to force an already-installed package to reinstall, a new copy of that package will be made in `lib` and then loaded from there. This means that you can potentially have several copies of the same package across many folders on your machine, each a different version. This allows you to maintain a different library folder for different projects, so that updated packages in Project B wil not affect the package versions you rely on for Project A.

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

### `unshelf`

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

### `reshelf`

`reshelf()` detaches and then reattaches packages. This is useful when you have a personal package, because you'll often find yourself adding a function to it and rebuilding it in one instance of RStudio, and then reloading the new build in a different RStudio instance that contains your actual work. Its return value is identical to `shelf()`.

``` r
reshelf(DesiQuintans/desiderata)

# is identical to

unshelf(DesiQuintans/desiderata, safe = FALSE, warn = FALSE))
  shelf(DesiQuintans/desiderata)
```

### `lib_paths`

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
