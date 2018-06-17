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

## Project participants

-   Desi Quintans (<https://twitter.com/eco_desi>)

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

---

## Functions included

|    Function | Example                                          | Description                                                                     |
| ----------: | :----------------------------------------------- | :------------------------------------------------------------------------------ |
|   `shelf()` | `shelf(janitor, DesiQuintans/desiderata, purrr)` | Attach packages to the search path, installing them from CRAN or GitHub if needed. |
| `unshelf()` | `unshelf(janitor, desiderata, purrr)`            | Detach packages from the search path.                                           |
| `reshelf()` | `reshelf(desiderata)`                            | Detach and then reattach packages, helpful for refreshing a personal package.   |

---

## Examples

### `shelf`

`shelf()` attaches packages to the search path, first installing them from CRAN or GitHub if needed.

For CRAN packages, provide the package name as normal.  
For GitHub packages, provide the username and package name separated by `/`.

``` r
shelf(dplyr, DesiQuintans/desiderata, purrr)
```

To force all of the named packages to re-download and re-install, use `update_all = TRUE`. 

Note that this only updates the named packages and not their dependencies. To update dependencies also, run `devtools::update_packages(c("pkg1", "pkg2", ...))`. _As usual, be careful when updating packages; your old scripts might need to be updated if packages have changed their function behaviours._

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


```

### `unshelf`

When detaching GitHub packages with `unshelf()`, you can provide the package names only, or you can provide the full username/package identifier as you did with `shelf()`. 

If you want to refresh a package by detaching and then reattaching it, use `reshelf()`.

``` r
# These are the same:

unshelf(janitor, desiderata, purrr)
unshelf(janitor, DesiQuintans/desiderata, purrr)
```

### `reshelf`

`reshelf()` detaches and then reattaches packages. This is useful when you have a personal package, because you'll often find yourself adding a function to it and rebuilding it in one instance of RStudio, and then reloading the new build in a different RStudio instance that contains your actual work. 

``` r
reshelf(DesiQuintans/desiderata)

# is identical to

unshelf(DesiQuintans/desiderata)
  shelf(DesiQuintans/desiderata)
```
