# Package management

#' Attach packages to the search path, installing them from CRAN or GitHub if needed
#'
#' @param ... (Names) Packages as bare names. If the package is from GitHub,
#'    include both the username and package name as UserName/package (see examples).
#' @param update_all (Logical) If `TRUE`, the packages will be re-installed even if they
#'    are already in your library.
#' @param quiet (Logical) Suppresses most warnings and messages.
#' @param custom_repo (`FALSE` or Character) Use `FALSE` for the default mirror (in 
#'    RStudio you can set a default mirror via _Options > Packages > Default CRAN Mirror_). 
#'    Otherwise, provide the URL to a CRAN mirror (e.g. "https://cran.csiro.au/").
#'
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    requested in `...` and `TRUE` means that the package was successfully installed 
#'    and attached.
#' @export
#'
#' @examples
#' # shelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' # shelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' # print(.Last.value)
#' 
#' #> janitor desiderata      purrr 
#' #>    TRUE       TRUE       TRUE 
#' 
#' @md
shelf <- function(..., update_all = FALSE, quiet = FALSE, custom_repo = FALSE) {
    # custom_repo = FALSE instead of NULL because NULL signals installation from local files.
    if (custom_repo == FALSE) {  
        custom_repo <- getOption("repos")
    }
    
    # 1. Get dots (which contains all the packages I want)
    packages <- nse_dots(..., keep_user = TRUE)

    # 2. Separate the GitHub packages from the CRAN ones. They'll contain a forward-slash.
    github_pkgs <- grep("^.*?/.*?$", packages, value = TRUE)
    github_bare_pkgs <- sub(".*?/", "", github_pkgs)
    
    cran_pkgs <- packages[!(packages %in% github_pkgs)]
    all_pkgs <- append(cran_pkgs, github_bare_pkgs)
    
    # 3a. If a package is missing from the library, install it.
    # 3b. To force packages to update, just pretend that they're all missing.
    if (update_all == TRUE) {
        cran_missing   <- cran_pkgs
        github_missing <- github_pkgs
    } else {
        cran_missing   <- cran_pkgs[which(!cran_pkgs %in% check_installed())]
        github_missing <- github_pkgs[which(!check_installed(github_bare_pkgs))]
    }

    if (length(cran_missing) > 0) {
        utils::install.packages(cran_missing, quiet = quiet, repos = custom_repo)
    }
    
    if (length(github_missing) > 0) {
        devtools::install_github(github_pkgs, quiet = quiet)
    }

    # 4. Find the packages that aren't attached yet.
    not_attached <- all_pkgs[which(!check_attached(all_pkgs))]
    
    # 5. Attach those packages.
    if (length(not_attached) > 0) {
        lapply(not_attached, library, character.only = TRUE, quietly = quiet)
    }
    
    return(invisible(check_attached(all_pkgs)))
}


#' Detach (unload) packages from the search path
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name.
#' @param everything (Logical) If this is `TRUE`, detach every non-default package 
#'    including librarian. Any names in `...` are ignored. The default packages can 
#'    be listed with `getOption("defaultPackages")`.
#'    
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    and `TRUE` means that the package was successfully detached.
#' @export
#'
#' @examples
#' # These are the same:
#' 
#' # unshelf(janitor, desiderata, purrr)
#' # unshelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' # unshelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' # print(.Last.value)
#' 
#' #> janitor desiderata      purrr 
#' #>    TRUE       TRUE       TRUE 
#' 
#' # unshelf(everything = TRUE)
#' # print(.Last.value)
#' 
#' #> librarian testthat
#' #> TRUE      TRUE
#' 
#' @md
unshelf <- function(..., everything = FALSE) {
    attached <- check_attached()
    
    if (everything == TRUE) {
        # Detach everything that isn't a base package.
        base_pkgs <- c(getOption("defaultPackages"), "base")  # Base is not a default package!
        to_detach <- attached[which(!attached %in% base_pkgs)]
    } else {
        # Detach only the packages that are listed.
        bare_pkgs <- nse_dots(..., keep_user = FALSE)
        to_detach <- bare_pkgs[which(bare_pkgs %in% attached)]
    }
    
    # Need to add a "package:" descriptor to the start of names for detach().
    to_detach_prefixed <- sub("^", "package:", to_detach)
    
    if (length(to_detach_prefixed) > 0) {
        lapply(to_detach_prefixed, detach, unload = TRUE, character.only = TRUE)
    }

    return(invisible(!check_attached(to_detach)))  # Invert so that TRUE = detached.
}

#' Detach and then reattach packages to the search path
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name.
#'
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    requested in `...` and `TRUE` means that the package was successfully attached.
#' @export
#'
#' @examples
#' # reshelf(desiderata)
#' 
#' # reshelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' # print(.Last.value)
#' 
#' #> desiderata 
#' #>       TRUE
#' 
#' 
#' @md
reshelf <- function(...) {
    unshelf(...)
    attached_status <- shelf(...)
    
    return(invisible(attached_status))
}
