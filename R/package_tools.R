# Package management


#' Attach packages to the search path, installing them from CRAN or GitHub if needed
#'
#' @param ... (Names) Packages as bare names. If the package is from GitHub,
#'    include both the username and package name as UserName/package (see examples).
#' @param update_all (Logical) If `TRUE`, the packages will be re-installed even if they
#'    are already in your library.
#' @param quiet (Logical) Suppresses most warnings and messages.
#' @param cran_repo (Character) In RStudio, a default CRAN repo can be set via 
#'    _Options > Packages > Default CRAN Mirror_). Otherwise, provide the URL to CRAN or 
#'    one of its mirrors (e.g. "https://cran.r-project.org").
#'
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    requested in `...` and `TRUE` means that the package was successfully installed 
#'    and attached.
#' @export
#'
#' @examples
#' 
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
shelf <- function(..., update_all = FALSE, quiet = FALSE, cran_repo = getOption("repos")) {
    # Automated testing fails with devtools::check() (but passes with devtools::test()) if
    # the repo arg for install.packages() is not set properly. If I run getOption("repos")
    # in R.exe running in the shell, I get the named vector c("CRAN" = "@CRAN@"), which is
    # probably what was causing the error. To catch this, I'll test whether cran_repo is 
    # a URL.
    
    # Regex is "@stephenhay" from https://mathiasbynens.be/demo/url-regex because it's the 
    # shortest regex that matches every CRAN mirror at https://cran.r-project.org/mirrors.html
    cran_repo_is_url <- grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", cran_repo)
    
    if (cran_repo_is_url == FALSE) {
        if (quiet == FALSE) {
            warning("cran_repo = '", as.character(cran_repo), "' is not a valid URL. 
                    Defaulting to cran_repo = 'https://cran.r-project.org'.")
        }
        
        # Default to the official CRAN site because it's future-proof.
        cran_repo <- "https://cran.r-project.org"
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

        # If safe, don't detach packages that other still-attached packages need.
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




#' Changing and viewing the package search paths
#' 
#' Can add an existing folder to the library trees (the list of folders that R will 
#' look inside when trying to find a package), or create a completely new folder and then 
#' add it, or shuffle a folder to the front of the list so that it is used as the default 
#' installation location for new packages in the current session.
#'
#' @param path (Character, or omit) A path to add to the library search path. Can be an 
#'     absolute or relative path. If `path` has more than one element, only the first 
#'     one will be kept. Tilde expansion is performed on the input, but wildcard expansion 
#'     (globbing) is not. If `path` is omitted, return the current library search path.
#' @param make_path (Logical) If `TRUE`, create `path`'s directory structure if it doesn't 
#'     exist.
#' @param ask (Logical) If `TRUE`, ask before creating `path`'s directory structure if 
#'     `make_path = TRUE`. Ignored if `make_path = FALSE`.
#'
#' @return A character vector of the folders on the library search path. If `path` was not 
#'     omitted, it will be the first element.
#' @export
#'
#' @examples
#' \donttest{
#' lib_paths()
#' #> [1] "D:/R/R-3.5.0/library"
#' 
#' lib_paths(file.path(tempdir(), "newlibraryfolder"), ask = FALSE)
#' #> [1] "C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder"
#' #> [2] "D:/R/R-3.5.0/library"
#' }
#' 
#' @md
lib_paths <- function(path, make_path = TRUE, ask = TRUE) {
    if (missing(path)) {
        return(.libPaths())
    }
    
    if (is.null(path) || is.na(path) || nchar(path) == 0) {
        # Standard behaviour for install.packages() and install_github() is to use the 
        # first element in .libPaths().
        path <- .libPaths()[1]
    }
    
    # Consistent with the behaviour above, keep only the first element of 'folder' in case
    # it has more than one. 
    
    # Tilde expansion is done just like .libPaths(), except I use normalizePath() 
    # instead of path.expand() so that 'folder' is an absolute path.
    
    # Unlike .libPaths(), wildcard expansion (globbing) is NOT done because it fails when
    # the user offers a library folder that doesn't exist yet (presumably so it can be
    # created by this very function).
    path <- normalizePath(path[1], winslash = "/", mustWork = FALSE)
    
    if (dir.exists(path) == FALSE) {
        if (make_path == FALSE) {
            stop("The path '", 
                 normalizePath(path, winslash = "\\", mustWork = FALSE),
                 "' does not exist. To create it, set the argument make_path = TRUE.")
        }
        
        if (ask == TRUE && interactive() == FALSE) {
            # The user can't be prompted, so do nothing rather than create folders unattended.
            stop("The library path will not be created because the user can't be prompted
                 while R is running non-interactively. To create the folder without 
                 prompting, set the argument ask = FALSE.")
        }
        
        if (ask == TRUE) {
            ans <- utils::askYesNo(paste0("The requested library folder does not exist:\n\n", 
                                   normalizePath(path, winslash = "\\", mustWork = FALSE),
                                   "\n\nCreate it?"), 
                            default = FALSE)
            
            if (ans == FALSE || is.na(ans)) {
                stop("The path '", 
                     normalizePath(path, winslash = "\\", mustWork = FALSE), 
                     "' does not exist and was not created.")
            }
        }
        
        # make_folder = TRUE --- user said yes --- ask = FALSE
        # Build the whole dir structure leading to 'folder' and return an absolute path to it.
        path <- make_dirs(path)  
    }
    
    if (file.access(path, 2) < 0) {  # -1 indicates dir not writeable
        stop("The path '", path, "' is not writeable.")
    }
    
    # There is no need to check whether 'folder' already appears in .libPaths(); it will
    # not be duplicated when it's prepended.
    .libPaths(c(path, .libPaths()))
    
    return(.libPaths())
}
