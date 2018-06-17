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
        cran_repo <- getOption("repos")
        
        # Automated testing fails with devtools::check() (but succeeds with
        # devtools::test() heh) if the repo arg for install.packages is not set properly.
        # After much weeping and gnashing of teeth from trying to work out what check()
        # actually sees when it accesses getOption("repos"), I have found that testing
        # whether getOption("repos") returns a URL works to catch whatever it is.
        
        # This regex matches all CRAN mirrors at https://cran.r-project.org/mirrors.html
        if (grepl("^.*?\\.?[\\w\\d\\-\\.]+\\..*?$", paste(cran_repo, collapse = "/")) == FALSE) {
            # Default to the official CRAN site because it's future-proof.
            cran_repo <- "https://cran.r-project.org"
        }
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
        utils::install.packages(cran_missing, quiet = quiet, repos = cran_repo)
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
    
    return(invisible(check_attached(nse_dots(..., keep_user = FALSE))))
}



#' Detach (unload) packages from the search path
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name.
#' @param everything (Logical) If this is `TRUE`, detach every non-default package 
#'    including librarian. Any names in `...` are ignored. The default packages can 
#'    be listed with `getOption("defaultPackages")`.
#' @param also_depends (Logical) If this is `TRUE`, also detach the dependencies of the 
#'    packages listed in `...`. This can be slow.
#' @param safe (Logical) If this is `TRUE`, packages won't be detached if they are needed 
#'    by other packages that are **not** listed in `...`.
#' @param quiet (Logical) If this is `FALSE`, show a message when packages can't be 
#'    detached because they are still needed by other packages.
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
unshelf <- function(..., everything = FALSE, also_depends = FALSE, safe = TRUE, quiet = TRUE) {
    attached <- check_attached()
    
    if (everything == TRUE) {
        # Detach everything that isn't a base package.
        base_pkgs <- c(getOption("defaultPackages"), "base")  # Base is absent from the list
        to_detach <- attached[which(!attached %in% base_pkgs)]
    } else {
        # Detach only the packages that are requested.
        pkgs_chosen <- nse_dots(..., keep_user = FALSE)
        
        # If chosen, also detach the dependencies of the listed packages.
        if (also_depends == TRUE) {
            # Get the dependency list of the packages named in ...
            deps_chosen <- tools::package_dependencies(pkgs_chosen, which = c("Depends", "Imports"))
            deps_chosen <- unique(unname(unlist(deps_chosen)))
            
            # Don't detach the default packages.
            deps_chosen <- deps_chosen[which(!deps_chosen %in% c(getOption("defaultPackages"), "base"))]
            
            pkgs_chosen <- unique(append(pkgs_chosen, deps_chosen))
        }
        
        to_detach <- pkgs_chosen[which(pkgs_chosen %in% attached)]

        # If chosen, don't detach packages that other still-attached packages need.
        if (safe == TRUE) {
            # Get the dependency list of the attached packages NOT named in ...
            pkgs_remaining <- attached[which(!attached %in% pkgs_chosen)]
            deps_remaining <- tools::package_dependencies(pkgs_remaining, which = c("Depends", "Imports"))
            deps_remaining <- unique(unname(unlist(deps_remaining)))

            to_detach <- to_detach[which(!to_detach %in% deps_remaining)]
        }
    }
    
    # Need to add a "package:" descriptor to the start of names for detach().
    to_detach_prefixed <- sub("^", "package:", to_detach)
    
    if (length(to_detach_prefixed) > 0) {
        suppressWarnings(
            lapply(to_detach_prefixed, detach, unload = TRUE, character.only = TRUE)
        )
    }

    result <- !check_attached(pkgs_chosen)
    
    if ((quiet == FALSE) & (sum(result) < length(result))) { # There are FALSEs in the vector.
        message("Some packages were not detached because other packages still need them:\n  ",
                paste(names(result[result == FALSE]), collapse = "  "),
                "\n  To force them to detach, use the 'safe = FALSE' argument.")
    }
    
    return(invisible(result))  # Invert so that TRUE = detached.
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
    unshelf(..., safe = FALSE, warn = FALSE)
    attached_status <- shelf(...)
    
    return(invisible(attached_status))
}
