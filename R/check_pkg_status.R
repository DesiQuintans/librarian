
# Checking package statuses -----------------------------------------------


#' Check if packages are installed or attached
#'
#' @param ... (Dots) Package names as bare names, strings, or a vector of strings.
#'    If left blank, returns a list of all packages that are installed/attached
#'    depending on the value of `status`.
#' @param status (Character) `"installed"` checks if packages are installed. 
#'    `"attached"` checks if packages are currently attached.
#' @param use_list (Logical) If `TRUE`, a character vector of package names was
#'    passed in `..1`, so use that as the results list. This is for programming 
#'    use; `nse_dots()` already detects if a char vector of length > 1 is in 
#'    `..1` and uses it as the package list automatically, but it does not do 
#'    that for char vectors of length 1 because the user can offer a mix of names
#'    and strings to `...` as a convenience.
#'
#' @return If `dots` is empty, a character vector of package names. Otherwise,
#'    return a named logical vector where `TRUE` means the package is installed
#'    or attached, depending on the value of `status`.
#' 
#' @md
check_pkg_status <- function(..., status, use_list = FALSE) {
    list <- switch(status, 
                   installed = rownames(utils::installed.packages()),
                   attached  = .packages())
    
    if (dots_is_empty(...)) {
        # User is asking for a list of all attached packages.
        return(list)
    } else {
        # User is asking if particular packages are attached.
        if (use_list == TRUE) {
            dots <- ..1
        } else {
            dots <- nse_dots(...)
        }
        
        status <- dots %in% list
        names(status) <- dots
        return(status)
    }
}



#' List the dependencies of selected packages
#'
#' @param of_pkgs (Character) Packages whose dependencies will be found.
#' @param which (Character) The types of dependencies to find.
#'
#' @return A character vector of package names. Note that all dependencies of 
#'    all requested packages will be placed into the one vector.
list_dependencies <- function(of_pkgs, which = c("Depends", "Imports")) {
    deps_chosen <- tools::package_dependencies(of_pkgs, which = which)
    all_deps <- unique(unname(unlist(deps_chosen)))
    
    if (is.null(all_deps)) {
        return(character(0))
    } else {
        all_deps
    }
}
