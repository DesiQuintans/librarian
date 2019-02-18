# Package management


#' Attach packages to the search path, installing them from CRAN, GitHub, or Bioconductor if needed
#'
#' @param ... (Names) Packages as bare names. If the package is from GitHub,
#'    include both the username and package name as UserName/package (see examples).
#' @param lib (Character) The path to the folder where new packages will be installed. The 
#'    folder will be added to the package search path. If the folder doesn't exist, you 
#'    will be prompted to create it if `ask = TRUE`, otherwise it will be silently 
#'    created. Can be an absolute or relative path. Tilde expansion is performed on the 
#'    input, but wildcard expansion (globbing) is not. If `lib` has more than one element, 
#'    only the first one will be kept. Defaults to the current library search path. See 
#'    the 'Details' section below for more information.
#' @param update_all (Logical) If `TRUE`, the packages will be re-installed even if they
#'    are already in your library.
#' @param quiet (Logical) If `TRUE`, suppresses most warnings and messages.
#' @param ask (Logical) If `TRUE`, and `lib` points to a folder that doesn't exist, ask 
#'    before creating the folder. If `FALSE`, the folder will be created silently.
#' @param cran_repo (Character) In RStudio, a default CRAN repo can be set via 
#'    _Options > Packages > Default CRAN Mirror_). Otherwise, provide the URL to CRAN or 
#'    one of its mirrors. If an invalid URL is given, defaults to https://cran.r-project.org.
#' @param bioc_repo (Character) If you use Bioconductor, you can set the repo URLs for it here.
#'    Defaults to Bioconductor's defaults (view them with `BiocInstaller::biocinstallRepos()`).
#'
#' @details  
#' You may choose to organise your library into folders to hold packages for different 
#' tasks or projects. If you specify a `lib` folder, it will be created (if needed) and 
#' attached to the package search path. R will look for packages by working through the 
#' package search path in order. You can view the folders that are on this path by 
#' calling `lib_paths()` with no arguments.
#' 
#' If you specify a new `lib` and use the argument `update_all = TRUE` to force an 
#' already-installed package to reinstall, a new copy of that package will be made in 
#' `lib` and then loaded from there. This means that you can potentially have several 
#' copies of the same package across many folders on your machine, each a different 
#' version. This allows you to maintain a different library folder for different projects, 
#' so that updated packages in Project B will not affect the package versions you rely on 
#' for Project A.
#'
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    requested in `...` and `TRUE` means that the package was successfully installed 
#'    and attached.
#' @export
#'
#' @examples
#' \donttest{
#' shelf(fortunes, DesiQuintans/emptyRpackage, cowsay, lib = tempdir(), update_all = TRUE)
#' 
#' # shelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' print(.Last.value)
#' 
#' #> fortunes desiderata     cowsay 
#' #>     TRUE       TRUE       TRUE
#' }
#' 
#' @md
shelf <- function(..., lib = lib_paths(), update_all = FALSE, quiet = FALSE, ask = TRUE, 
                  cran_repo = getOption("repos"), bioc_repo = character()) {
    if (is_dots_empty(...) == TRUE) {
        # Errors should not be 'quiet'-able.
        stop("No packages were chosen for attaching.")
    }
    
    # install_github() lacks a `lib` argument and always installs to the first element 
    # in .libPaths(). The install location must therefore be controlled by adding new 
    # folders to the front of .libPaths(). lib_paths() is a wrapper that also includes
    # automatic folder creation as a convenience to the user.
    lib_paths(lib, make_path = TRUE, ask = ask)
    
    # Automated testing fails with devtools::check() (but passes with devtools::test()) if
    # the repo arg for install.packages() is not set properly. If I run getOption("repos")
    # in R.exe running in the shell, I get the named vector c("CRAN" = "@CRAN@"), which is
    # probably what was causing the error. To catch this, I'll test whether cran_repo is 
    # a URL.
    
    # Regex is "@stephenhay" from https://mathiasbynens.be/demo/url-regex because it's the 
    # shortest regex that matches every CRAN mirror at https://cran.r-project.org/mirrors.html
    cran_repo_is_url <- grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", cran_repo)
    
    if (any(cran_repo_is_url) == FALSE) {
        if (quiet == FALSE) {
            if (cran_repo == "@CRAN@") {
                # Special case for R's default CRAN placeholder value.
                # See issue #10: https://github.com/DesiQuintans/librarian/issues/10
                message("The 'cran_repo' argument in shelf() was not set, so it will \n",
                        "use cran_repo = 'https://cran.r-project.org' by default.\n\n",
                        "To avoid this message, set the 'cran_repo' argument to a\n",
                        "CRAN mirror URL (see https://cran.r-project.org/mirrors.html)\n", 
                        "or set 'quiet = TRUE'.")
            } else {
                warning("This is not a valid URL: cran_repo = '", as.character(cran_repo), "'\n", 
                        "Defaulting to cran_repo = 'https://cran.r-project.org'.")
            }
        }
        
        # Default to the official CRAN site because it's future-proof.
        cran_repo <- "https://cran.r-project.org"
    }
    
    # 1. Get dots (which contains the requested package names).
    packages <- nse_dots(..., keep_user = TRUE)

    # 2. Separate the GitHub packages from the CRAN ones. They'll contain a forward-slash.
    github_pkgs <- grep("^.*?/.*?$", packages, value = TRUE)
    github_bare_pkgs <- sub(".*?/", "", github_pkgs)
    
    cran_pkgs <- packages[!(packages %in% github_pkgs)]  # This may also contain Bioconductor pkgs.
    all_pkgs <- append(cran_pkgs, github_bare_pkgs)
    
    # 3a. If a package is missing from the library, install it.
    # 3b. To force packages to update, just pretend that they're all missing.
    if (update_all == TRUE) {
        cran_missing   <- cran_pkgs
        github_missing <- github_pkgs
    } else {
        cran_missing   <- cran_pkgs[which(!check_installed(cran_pkgs))]
        github_missing <- github_pkgs[which(!check_installed(github_bare_pkgs))]
    }
    
    if (length(cran_missing) > 0) {
        suppressWarnings(  # Warnings from trying to install non-CRAN packages (i.e. Bioconductor).
            suppress_lib_message(  # "Installing package into ... (as ‘lib’ is unspecified)"
                utils::install.packages(cran_missing, quiet = quiet, repos = cran_repo)
            )
        )
    }
    
    if (length(github_missing) > 0) {
        suppress_lib_message(
            remotes::install_github(github_missing, quiet = quiet)
        )
    }
    
    # 4. CRAN packages that failed to install may be Bioconductor packages.
    cran_still_missing <- cran_missing[which(!check_installed(cran_missing))]
    
    if (length(cran_still_missing) > 0 & check_installed("Biobase") == TRUE) {
        # eval_quietly(
        suppressWarnings(
            # By my understanding, install with `suppressUpdates = TRUE` will
            # automatically update the requested Bioconductor packages, but will NOT
            # update all other installed packages too. I tried running it with
            # `ask = FALSE` and it updated everything in my R installation :/
            BiocManager::install(cran_still_missing, site_repository = bioc_repo,
                                 update = FALSE, ask = FALSE, quiet = quiet)
        )
    }
    
    # 5a. Find the packages that aren't attached yet.
    # 5b. Omit any packages that failed installation.
    not_attached <- all_pkgs[which(check_installed(all_pkgs) == TRUE & check_attached(all_pkgs) == FALSE)]
    failed_install <- all_pkgs[which(!check_installed(all_pkgs))]
    
    # 6. Attach those packages.
    if (length(not_attached) > 0) {
        # Bioconductor packages have SO MANY annoying package startup messages that 
        # are actually just sent as plain messages.
            lapply(not_attached, library, character.only = TRUE, quietly = quiet)
    }
    
    if (length(failed_install) > 0) {
        warning("\n\n  These packages failed to install and were not attached:\n\n",
                "    ", paste(failed_install, collapse = ", "), "\n\n",
                "  Are they Bioconductor packages? If so, please install Bioconductor\n",
                "  before running librarian::shelf().\n\n",
                "  Are they from GitHub? Please supply both the GitHub username and\n",
                "  package name, e.g. DesiQuintans/librarian\n\n",
                "  Otherwise, check the spelling and capitalisation of the names.\n",
                "  It's also possible that the packages are someone's private packages\n",
                "  that are not being shared online.")
    }
    
    return(invisible(check_attached(nse_dots(..., keep_user = FALSE))))
}



#' Detach (unload) packages from the search path
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name.
#' @param everything (Logical) If `TRUE`, detach every non-default package including
#'    librarian. Any names in `...` are ignored. The default packages can be listed
#'    with `getOption("defaultPackages")`.
#' @param also_depends (Logical) If `TRUE`, also detach the dependencies of the packages
#'    listed in `...`. This can be slow.
#' @param safe (Logical) If `TRUE`, packages won't be detached if they are needed by other
#'    packages that are **not** listed in `...`.
#' @param quiet (Logical) If `FALSE`, show a message when packages can't be detached 
#'    because they are still needed by other packages.
#'    
#' @return Invisibly returns a named logical vector, where the names are the packages 
#'    and `TRUE` means that the package was successfully detached.
#' @export
#'
#' @examples
#' \donttest{
#' # These are the same:
#' 
#' unshelf(janitor, desiderata, purrr)
#' unshelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' # unshelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' print(.Last.value)
#' 
#' #> desiderata    janitor      purrr 
#' #>       TRUE       TRUE       TRUE 
#' 
#' unshelf(everything = TRUE)
#' print(.Last.value)
#' 
#' #> librarian testthat
#' #> TRUE      TRUE
#' }
#' 
#' @md
unshelf <- function(..., everything = FALSE, also_depends = FALSE, safe = TRUE, quiet = TRUE) {
    
    
    if (is_dots_empty(...) == TRUE && everything == FALSE) {
        # Errors should not be 'quiet'-able.
        stop("No packages were chosen for detaching. Either provide the names of ", 
             "packages, or set 'everything = TRUE' to detach all non-Base packages.")
    }
    
    attached <- check_attached()
    
    if (everything == TRUE) {
        # Detach everything that isn't a base package.
        base_pkgs <- c(getOption("defaultPackages"), "base")  # Base is absent from the list
        to_detach <- attached[which(!attached %in% base_pkgs)]
        pkgs_chosen <- to_detach  # HACK: Pretend that the user named all of these non-Base packages.
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

    result <- !check_attached(sort(unique(c(pkgs_chosen, to_detach))))  # Invert so that TRUE means 'detached'.
    
    if ((quiet == FALSE) & (sum(result) < length(result))) { # If result has FALSEs.
        message("Some packages were not detached because other packages still need them:\n  ",
                paste(names(result[result == FALSE]), collapse = "  "),
                "\n  To force them to detach, use the 'safe = FALSE' argument.")
    }
    
    return(invisible(result))  
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
#' \donttest{
#' reshelf(datasets)
#' 
#' # reshelf() returns invisibly; bind its output to a variable or access the .Last.value.
#' 
#' print(.Last.value)
#' 
#' #> datasets 
#' #>     TRUE
#' }
#' 
#' @md
reshelf <- function(...) {
    unshelf(..., safe = FALSE, warn = FALSE)
    attached_status <- shelf(..., quiet = TRUE)
    
    return(invisible(attached_status))
}




#' Changing and viewing the package search paths
#' 
#' View and edit the list of folders that R will look inside when trying to find a 
#' package. Add an existing folder, create and add a new folder, or shuffle a folder to 
#' the front of the list so that it is used as the default installation location for new 
#' packages in the current session.
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
#' 
#' #> [1] "D:/R/R-3.5.0/library"
#' 
#' lib_paths(file.path(tempdir(), "newlibraryfolder"), ask = FALSE)
#' 
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
            stop("The library path will not be created because the user can't be prompted ",
                 "while R is running non-interactively. To create the folder without ", 
                 "prompting, set the argument ask = FALSE.")
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



#' Set packages and library paths to automatically start-up with R
#'
#' This function writes code to a .Rprofile file that R reads at the start of every new 
#' session.
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name. If you leave `...` blank, R will only load its default packages (see Details).
#' @param lib (Character) The path where packages are installed. Can be an 
#'     absolute or relative path. If `path` has more than one element, only the first 
#'     one will be kept. Tilde expansion is performed on the input, but wildcard expansion 
#'     (globbing) is not. Defaults to the current library search path.
#' @param global (Logical) If `TRUE`, write these settings to a .Rprofile file in the home
#'    directory (on Windows, the My Documents folder). If `FALSE`, write them to a 
#'    .Rprofile file that is in the current directory (i.e. the RStudio project's folder, 
#'    or the current working directory). See Details for more.
#'
#' @details R's startup order is mentioned in `?Startup`, but briefly:
#'    1. R tries to load the environmental variables file (Renviron.site)
#'    2. R tries to load the site-wide profile (Rprofile.site)
#'    3. R tries to load the user profile (.Rprofile), first in the current directory, and 
#'       then in the user's home directory (on Windows, the My Documents folder). 
#'       **Only one of these files is sourced into the workspace.**
#'       
#'    Omitting `...` makes R load only its default packages. If these are not set in an
#'    environmental variable (`R_DEFAULT_PACKAGES`), then R will default to loading these 
#'    packages: datasets, utils, grDevices, graphics, stats, and methods.
#'
#' @return A message listing the values that were written to the .Rprofile file.
#' @export
#'
#' @examples
#' \donttest{
#' lib_startup(librarian)
#' 
#' lib_startup(librarian, dplyr, lubridate)
#' }
#' 
#' @md
lib_startup <- function(..., lib = lib_paths(), global = TRUE) {
    # 1. Check that the library path folders exist.
    paths <- lib_paths(lib, make_path = TRUE, ask = TRUE)
        
    # 2. Check if dots is empty or not.
    if (is_dots_empty(...) == TRUE) {
        packages <- character(0)
    } else {
        packages <- nse_dots(..., keep_user = FALSE)
    }

    # 3. If dots is not empty, check that the packages are all installed.
    if (length(packages) > 0) {
        status <- check_installed(packages)
        
        if (any(!status)) { # !status so that the failed packages are TRUE.
            # There was a package that was not installed in the search path.
            stop("Some requested packages are not installed in the current library path:\n\n  ",
                 paste(names(status[status == FALSE]), collapse = "  "), "\n\n",
                 "  Use shelf() to install them, or if they are already installed, use\n", 
                 "  the 'lib' argument to point to the folder they are installed in.")
        }
    }
    
    # 4. Reset the defaultPackages option.
    def_pkgs <- Sys.getenv("R_DEFAULT_PACKAGES")
    
    if (nchar(def_pkgs) == 0) {
        # This environment var is unset, so default to R's list of packages.
        # See 'defaultPackages' entry in ?getOption for details.
        def_pkgs <- c("datasets", "utils", "grDevices", "graphics", "stats", "methods")
    }
    
    # 5. Build the lines that are going to be printed to the Rprofile.
    libr_marker <- "  # Added by librarian::lib_startup()."
    path_output <- collapse_vec(paths)
    pkgs_output <- collapse_vec(def_pkgs, packages)
    
    path_lines <- paste0('\n.libPaths(c(', 
                         path_output, 
                         '))', 
                         libr_marker)
    
    pkgs_lines <- paste0('\noptions(defaultPackages = c(', 
                         pkgs_output, 
                         '))', 
                         libr_marker)

    # 6. Check if the .Rprofile file already exists, and remove Librarian code from it.
    file <- if (global == TRUE) "~/.Rprofile" else file.path(getwd(), ".Rprofile")

    if (file.exists(file)) {
        lines <- readLines(file)
        lines <- lines[grepl(libr_marker, lines, fixed = TRUE) == FALSE]
    } else {
        lines <- character(0)
    }

    # 7. Print the lines to the file
    cat(lines,      file = file, append = FALSE)  # Replace contents of file first.
    cat(path_lines, file = file, append = TRUE)
    cat(pkgs_lines, file = file, append = TRUE)
    cat("\r\n",     file = file, append = TRUE)   # Terminate the file properly.

    message("Added library paths and startup packages to:\n  ", path.expand(file), "\n\n",
            "Library paths:\n  ", path_output, "\n\n",
            "Startup packages:\n  ", pkgs_output)
}
