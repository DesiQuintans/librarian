# Package management

#' Attach packages to the library, installing them from CRAN/GitHub if needed
#'
#' @param ... (Names) Packages as bare names. If the package is from GitHub,
#'    include both the username and package name as UserName/package (see examples).
#' @param update_all (Logical) If `TRUE`, the packages will be re-installed even if they
#'    already exist in your computer.
#' @param quiet (Logical) Suppresses most warnings and messages.
#' @param custom_repo (`FALSE` or Character) Use `FALSE` for the default mirror (in 
#'    RStudio you can set a default mirror via _Options > Packages > Default CRAN Mirror_). 
#'    Otherwise, provide the URL to a CRAN mirror (e.g. "https://cran.csiro.au/").
#'
#' @return Invisibly returns `devtools::session_info()`, which provides version info about
#'    your R and package installations.
#' @export
#'
#' @examples
#' # shelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' @md
shelf <- function(..., update_all = FALSE, quiet = FALSE, custom_repo = FALSE) {
    # custom_repo = FALSE instead of NULL because NULL allows installation from local files.
    if (custom_repo == FALSE) {  
        custom_repo <- getOption("repos")
    }
    
    # 1. Get dots (which contains all the packages I want)
    dots <- nse_dots(...)
    packages <- as.character(dots)
    packages <- unique(packages)

    # 2. Separate the GitHub packages from the CRAN ones. They'll contain a forward-slash.
    github_pkgs <- grep("^.*?/.*?$", packages, value = TRUE)
    github_bare_pkgs <- sub(".*?/", "", github_pkgs)
    cran_pkgs <- packages[!(packages %in% github_pkgs)]
    all_pkgs <- append(cran_pkgs, github_bare_pkgs)

    # 3. If not installed, install them.
    if (update_all == TRUE) {
        if (length(cran_pkgs) > 0) { 
            utils::install.packages(cran_pkgs, quiet = quiet, repos = custom_repo) 
        }
        
        if (length(github_pkgs) > 0) { 
            devtools::install_github(github_pkgs, quiet = quiet) 
        }
    } else {
        cran_missing <- cran_pkgs[which(!cran_pkgs %in% utils::installed.packages()[, 1])]
        github_missing <- github_pkgs[which(!github_bare_pkgs %in% utils::installed.packages()[, 1])]

        if (length(cran_missing) > 0) {
            utils::install.packages(cran_missing, quiet = quiet, repos = custom_repo)
        }

        if (length(github_missing) > 0) {
            devtools::install_github(github_pkgs, quiet = quiet)
        }
    }

    # 4. Find the ones that aren't attached yet.
    already_attached <- (.packages())
    not_attached <- all_pkgs[which(!all_pkgs %in% already_attached)]
    
    # 5. Load them all
    if (length(not_attached) > 0) {
        lapply(not_attached, library, character.only = TRUE, quietly = quiet)
    }
    
    return(invisible(devtools::session_info()))
}


#' Detach (unload) packages from the library
#'
#' @param ... (Names) Packages as bare names. For packages that come from GitHub, you can
#'    keep the username/package format, or omit the username and provide just the package 
#'    name.
#'    
#' @return Returns `NULL` invisibly.
#' @export
#'
#' @examples
#' # These are the same:
#' 
#' # unshelf(janitor, desiderata, purrr)
#' # unshelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' # You can quickly unload-reload packages by just changing 'shelf' to 'unshelf'.
#' 
#' #   shelf(janitor, DesiQuintans/desiderata, purrr)
#' # unshelf(janitor, DesiQuintans/desiderata, purrr)
#' 
#' @md
unshelf <- function(...) {
    dots <- nse_dots(...)
    packages <- as.character(dots)
    
    bare_pkgs <- sub(".*?/", "", packages)  # Remove GitHub username component, if any.
    bare_pkgs <- unique(bare_pkgs)
    
    package_list <- (.packages())
    attached_pkgs <- bare_pkgs[which(bare_pkgs %in% package_list)]

    attached_pkgs <- sub("^", "package:", attached_pkgs)
    
    if (length(attached_pkgs) > 0) {
        lapply(attached_pkgs, detach, unload = TRUE, character.only = TRUE)
    }

    return(invisible(NULL))
}
