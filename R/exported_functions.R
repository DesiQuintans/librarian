
# Installing, attaching, detaching packages -------------------------------



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

    # Sanitise user input
    if (dots_is_empty(...)) {
        stop(tell_user("no packages were chosen"))
    }
    
    packages <- nse_dots(..., keep_user = TRUE)
    
    # Make sure that the library path exists, and keep the first entry (it is
    # the one that the package installation functions use.
    lib <- lib_paths(lib, make_path = TRUE, ask = ask)[[1]]
    
    # CRAN's repo needs to be set to a valid URL or else it will create errors
    # in devtools::check(). 
    if (is_valid_url(cran_repo) == FALSE) {
        if (quiet == FALSE) {
            if (cran_repo == "@CRAN@") {
                # Special case for R's default CRAN placeholder value.
                # See issue #10: https://github.com/DesiQuintans/librarian/issues/10
                message(tell_user("fixed cran repo placeholder"))
            } else {
                warning(tell_user("invalid CRAN repo URL", cran_repo))
            }
        }
        
        # Default to the official CRAN site because it's future-proof.
        cran_repo <- "https://cran.r-project.org"
    }
    
    
    # 1. Separate the GitHub packages from the CRAN ones. They'll contain a forward-slash.
    github_pkgs <- grep("^.*?/.*?$", packages, value = TRUE)
    github_bare_pkgs <- sub(".*?/", "", github_pkgs)
    
    cran_pkgs <- packages[!(packages %in% github_pkgs)]  # This may also contain Bioconductor pkgs.
    all_pkgs <- append(cran_pkgs, github_bare_pkgs)
    
    
    # 2. Try to exit early by attaching packages. If not, determine which 
    # packages are missing and need to be installed.
    
    if (update_all == FALSE) {
        # 2a. If the user does not want to update packages, try to exit as soon
        # as possible by trying to attach them. Since the user will be attaching
        # already-installed packages more often than installing new ones, this
        # will let shelf() exit early most of the time.
        
        try_require <- function(pkgs) {
            suppressWarnings(require(pkgs, character.only = TRUE, quietly = quiet))
        }
        
        # Negated so that failed attachment is TRUE
        attach_result <- !vapply(all_pkgs, try_require, logical(1))
        
        if (any(attach_result)) {
            missing_pkgs <- names(attach_result[which(attach_result == TRUE)])
            
            # Only missing packages need to be installed
            cran_missing   <- cran_pkgs[which(cran_pkgs %in% missing_pkgs)]
            github_missing <- github_pkgs[which(github_bare_pkgs %in% missing_pkgs)]
            
            message(tell_user("these packages will be installed", missing_pkgs))
        } else {
            # Named logical vector of package names and TRUE if attached, just like
            # the value check_attached() returns.
            # Early exit.
            return(invisible(!attach_result)) 
        }
    } else {
        # 2b. To force packages to update, just pretend that they're all missing.
        cran_missing   <- cran_pkgs
        github_missing <- github_pkgs
    }
    
    if (length(cran_missing) > 0) {
        suppressWarnings(  # Warnings from trying to install non-CRAN packages (i.e. Bioconductor).
                utils::install.packages(cran_missing, lib = lib, 
                                        quiet = quiet, repos = cran_repo)
        )
    }
    
    if (length(github_missing) > 0) {
        suppressWarnings(
            remotes::install_github(github_missing, quiet = quiet, lib = lib)
        )
    }
    
    # 3. CRAN packages that failed to install may be Bioconductor packages.
    cran_still_missing <- cran_missing[which(!check_installed(cran_missing))]
    
    if (length(cran_still_missing) > 0 & check_installed("Biobase") == TRUE) {
        suppressWarnings(
            # By my understanding, install with `suppressUpdates = TRUE` will
            # automatically update the requested Bioconductor packages, but will NOT
            # update all other installed packages too. I tried running it with
            # `ask = FALSE` and it updated everything in my R installation :/
            BiocManager::install(cran_still_missing, site_repository = bioc_repo,
                                 update = FALSE, ask = FALSE, quiet = quiet, lib = lib)
        )
    }
    
    # 4a. Find the packages that aren't attached yet.
    # 4b. Omit any packages that failed installation.
    not_attached <- all_pkgs[which(check_installed(all_pkgs) == TRUE & check_attached(all_pkgs) == FALSE)]
    failed_install <- all_pkgs[which(!check_installed(all_pkgs))]
    
    # 5. Attach those packages.
    if (length(not_attached) > 0) {
        suppressPackageStartupMessages(
            lapply(not_attached, library, character.only = TRUE, quietly = quiet)
        )
    }
    
    if (length(failed_install) > 0) {
        warning(tell_user("some packages failed to install", failed_install))
    }
    
    # GitHub usernames need to be removed from the final list.
    bare_names <- sub("^.*?/", "", packages)
    
    return(invisible(check_attached(bare_names)))
}



#' Detach (unload) packages from the search path
#' 
#' Packages can be detached by themselves, with their dependencies safely (i.e. as  
#' long as those dependencies are not being used by other packages), or with their
#' dependencies unsafely (regardless of whether those dependencies are still needed).
#' All non-default packages can be detached at once too, including Librarian itself.
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
    if (dots_is_empty(...) == TRUE && everything == FALSE) {
        # Errors should not be 'quiet'-able.
        stop(tell_user("nothing to unshelf"))
    }
    
    # getOption("defaultPackages") does not always list only the base packages since
    # lib_startup() changes this variable to make packages load at the start of your
    # session. That's why I use sessionInfo()$basePkgs to list the base packages.
    
    session_info  <- utils::sessionInfo()
    base_pkgs     <- session_info$basePkgs
    user_pkgs     <- names(session_info$otherPkgs)
    attached      <- c(base_pkgs, user_pkgs)
    rprofile_pkgs <- c(getOption("defaultPackages"), "base")
    
    # Processes a vector of package names and then tries to detach them.
    detach_pkgs <- function(to_detach, full_list) {
        pkgs_prefixed <- sub("^", "package:", to_detach)
        
        if (length(pkgs_prefixed) > 0) {
            suppressWarnings(
                lapply(pkgs_prefixed, detach, unload = TRUE, character.only = TRUE)
            )
        }
        
        return(invisible(!check_attached(full_list)))  # Flip so that TRUE indicates successful detaching.
    }
    
    if (everything == TRUE) {
        if (safe == TRUE) {
            # Will keep the packages that the user has in their .Rprofile.
            detach_pkgs(attached[attached %notin% rprofile_pkgs])
        } else {
            # Will keep R's default package list only.
            detach_pkgs(attached[attached %notin% base_pkgs])
        }
    } else {
        # Will detach packages that were requested
        pkgs_chosen <- nse_dots(..., keep_user = FALSE)
        deps_chosen <- character(0)
        
        if (also_depends == TRUE) {
            # Populate the dependency list for the chosen packages.
            deps_chosen <- list_dependencies(pkgs_chosen)
        }
        
        candidates <- unique(c(pkgs_chosen, deps_chosen))
        to_detach <- candidates[candidates %in% attached]
        
        if (safe == TRUE) {
            # Get the dependency list of the attached packages NOT named in dots
            deps_not_chosen <- list_dependencies(attached[attached %notin% pkgs_chosen])
            
            pkgs_kept <- to_detach[to_detach %in% deps_not_chosen]
            to_detach <- to_detach[to_detach %notin% deps_not_chosen]
            
            if (quiet == FALSE & length(pkgs_kept) > 0) {
                message(tell_user("some packages still being used", pkgs_kept))
            }
        }
        
        full_list <- to_detach
        to_detach <- to_detach[to_detach %in% attached]
        
        detach_pkgs(to_detach, full_list)
    }
}



#' Detach and then reattach packages to the search path
#'
#' Convenience shortcut for force-`unshelf`ing packages and then `shelf`ing them again.
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



# Library paths and .Rprofile ---------------------------------------------

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
#' #> [1] "D:/R/R-3.5.2/library"
#' 
#' lib_paths(file.path(tempdir(), "newlibraryfolder"), ask = FALSE)
#' 
#' #> [1] "C:/Users/.../Temp/Rtmp0Qbvgo/newlibraryfolder"
#' #> [2] "D:/R/R-3.5.2/library"
#' }
#' 
#' @md
lib_paths <- function(path, make_path = TRUE, ask = TRUE) {
    existing_paths <- .libPaths()
    
    if (missing(path) || is.null(path) || is.na(path) || nchar(path) == 0) {
        return(existing_paths)
    }
    
    # Tilde expansion is done just like .libPaths(), except I use normalizePath()
    # instead of path.expand() so that 'folder' is an absolute path.
    
    # Unlike .libPaths(), wildcard expansion (globbing) is NOT done because it fails when
    # the user offers a library folder that doesn't exist yet (presumably so it can be
    # created by this very function).
    path      <- normalizePath(path, winslash = "/", mustWork = FALSE)
    exists    <- path[which(dir.exists(path))]
    non_exist <- path[path %notin% exists]
    
    
    # Some folders need to be created.
    if (length(non_exist) > 0) {
        if (make_path == FALSE) {
            stop(tell_user("not allowed to make path", non_exist))
        }
        
        if (ask == TRUE && interactive() == FALSE) {
            stop(tell_user("cannot get user feedback in a non-interactive session", non_exist))
        }
        
        if (ask == TRUE) {
            ans <- utils::askYesNo(tell_user("ask to create path", non_exist), default = FALSE)
            
            if (ans == FALSE || is.na(ans)) {
                stop(tell_user("lib paths were not created", non_exist))
            }
        }
        
        lapply(non_exist, make_dirs)
    }
    
    # Check that all folders are writeable
    permissions <- unlist(lapply(path, file.access, mode = 2))
    unwriteable <- permissions[which(permissions < 0)] # -1 means dir not writeable
    
    if (length(unwriteable) > 0) {  
        stop(tell_user("paths not writeable", unwriteable))
    }
    
    # All folders should now exist, and I can add them to the lib path. There is
    # no need to check whether 'folder' already appears in .libPaths(); it will
    # not be duplicated when it's prepended.
    .libPaths(c(path, existing_paths))
    
    return(.libPaths())
}



#' Set packages and library paths to automatically start-up with R
#'
#' This function tells R to load packages and library folders at the start of every
#' session (or on a per-project basis). It's best to keep this auto-load list to a 
#' minimum so that you don't forget to explicitly install/attach packages in scripts 
#' that need them.
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
#' lib_startup(librarian, magrittr, lib = "C:/Dropbox/My R Library")
#' }
#' 
#' @md
lib_startup <- function(..., lib = lib_paths(), global = TRUE) {
    # 1. Check that the library path folders exist.
    paths <- lib_paths(lib, make_path = TRUE, ask = TRUE)
    
    # 2. Check if dots is empty or not.
    if (dots_is_empty(...) == TRUE) {
        packages <- character(0)
    } else {
        packages <- nse_dots(..., keep_user = FALSE)
    }
    
    # 3. If dots is not empty, check that the packages are all installed.
    if (length(packages) > 0) {
        status <- check_installed(packages)
        
        if (any(!status)) { # !status so that the failed packages are TRUE.
            stop(tell_user("can't add uninstalled pkgs to .RProfile", 
                           names(status[status == FALSE])))
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
    cat("\n",       file = file, append = TRUE)   # Terminate the file properly.
    
    message(tell_user(".RProfile was edited", 
                      path.expand(file), paths, c(def_pkgs, packages)))
}



# Package discovery and search --------------------------------------------

#' Search for CRAN packages by keyword/regex
#'
#' Inspired by my mysterious inability to remember what the RColorBrewer package is 
#' actually called. Lets you find relevant CRAN packages right from your terminal.
#'
#' @param query (Character) A string to `grep()` for.
#' @param fuzzy (Logical) If `TRUE`, enables fuzzy orderless matching. Every word in
#'   `query` (i.e. every group of characters separated with a space) will be wrapped
#'   with a lookaround `(?=*KEYWORD)`. This will match keywords regardless
#'   of the order in which those words appear.
#' @param echo (Logical) If `TRUE`, print the results to the console.
#' @param ignore.case (Logical) If `TRUE`, ignore upper/lowercase differences while
#'   searching.
#'
#' @details When `browse_cran()` is run for the first time in a new session, it will 
#'    take about 6-12 seconds to download and cache CRAN data. This only happens once 
#'    per session; subsequent calls will use the cached copy.
#'
#' @return Invisibly returns a dataframe of the packages that matched the query 
#'   together with their descriptions. Prints results to the console.
#' @export
#'
#' @examples
#' \donttest{
#' browse_cran("colorbrewer")  # Search by keyword
#' 
#' #> RColorBrewer 
#' #>     Provides color schemes for maps (and other graphics) designed by Cynthia 
#' #>     Brewer as described at http://colorbrewer2.org 
#' #> 
#' #> Redmonder 
#' #>     Provide color schemes for maps (and other graphics) based on the color 
#' #>     palettes of several Microsoft(r) products.
#' 
#' 
#' browse_cran("zero-inflat.*?(abund|count)")  # Search by regular expression
#'
#' #> hurdlr 
#' #>     When considering count data, it is often the case that many more zero 
#' #>     counts than would be expected of some given distribution are observed.
#' 
#' # And five other matches...
#'
#'
#' browse_cran("network twitter api", fuzzy = TRUE)  # Order-agnostic (fuzzy) search
#'
#' #> RKlout 
#' #>     An interface of R to Klout API v2.
#' }
#' 
#' @md
browse_cran <- function(query, fuzzy = FALSE, echo = TRUE, ignore.case = TRUE) {
    # Downloading the CRAN package list is slow (10 seconds for me), so I only want
    # to do it once per session.
    
    temp_crandb_file <- file.path(tempdir(), "temp_cran_db.rds")
    
    if (!file.exists(temp_crandb_file)) {
        raw <- tools::CRAN_package_db()[c("Package", "Description")]
        raw["Description"] <- gsub("\\s+", " ", raw[["Description"]])
        raw["Description"] <- gsub("\\s?<.*>", "", raw[["Description"]])
        
        cran_db <- data.frame(Package = raw[["Package"]],
                              Description = raw[["Description"]],
                              Haystack = paste(raw[["Package"]], raw[["Description"]]),
                              stringsAsFactors = FALSE)
        
        saveRDS(cran_db, temp_crandb_file)
    } else {
        cran_db <- readRDS(temp_crandb_file)
    }
    
    # Matching unordered terms with PERL regex is super slow, so it's opt-in.
    
    if (fuzzy == TRUE) {
        query <- fuzzy_needle(query)
    }
    
    matching_rows <- grep(query, cran_db[["Haystack"]], 
                          ignore.case = ignore.case, perl = TRUE)
    
    if (length(matching_rows) == 0) {
        message("\nNo CRAN packages matched query: ", query, "\n")
        return(invisible(data.frame()))
    }
    
    # Remember to omit the "haystack" col.
    matches <- cran_db[matching_rows, c("Package", "Description")]
    matches <- unique(matches)  # Sometimes rows are duplicated for some reason.
    
    if (echo == TRUE) {
        for (i in 1:nrow(matches)) {
            cat(matches[[i, "Package"]], "\n")
            cat(wrap_text(sentence(matches[[i, "Description"]])), "\n\n")
        }
    }
    
    return(invisible(matches))
}



# Check package status ----------------------------------------------------

#' Check if packages are installed
#'
#' @param ... (Dots) Package names as bare names, strings, or a character vector. 
#'    If left empty, lists all installed packages.
#'
#' @return If `dots` is empty, a character vector of all installed packages. 
#'    Otherwise, return a named logical vector where `TRUE` means the package
#'    is installed.
#' @export
#'
#' @examples
#' \dontrun{
#' check_installed()
#' 
#' #>   [1] "addinslist"  "antiword" " ape"  "assertthat"  ...
#' 
#' check_installed(c("utils", "stats"))
#' 
#' #> utils stats 
#' #> TRUE  TRUE 
#' 
#' check_installed("datasets", "base", fakepkg)
#' 
#' #> datasets     base  fakepkg 
#' #>     TRUE     TRUE    FALSE 
#' }
#' 
#' @md
check_installed <- function(...) {
    check_pkg_status(..., status = "installed")
}



#' Check if packages are attached
#'
#' @param ... (Dots) Package names as bare names, strings, or a character vector. 
#'    If left empty, lists all attached packages.
#'
#' @return If `dots` is empty, a character vector of all attached packages. 
#'    Otherwise, return a named logical vector where `TRUE` means the package
#'    is attached
#' @export
#'
#' @examples
#' \dontrun{
#' check_attached()
#' 
#' #>   [1] "librarian" "testthat"  "magrittr"  "stats" ...
#' 
#' check_attached(c("utils", "stats"))
#' 
#' #> utils stats 
#' #> TRUE  TRUE 
#' 
#' check_attached("datasets", "base", fakepkg)
#' 
#' #> datasets     base  fakepkg 
#' #>     TRUE     TRUE    FALSE 
#' }
#' 
#' @md
check_attached <- function(...) {
    check_pkg_status(..., status = "attached")
}
