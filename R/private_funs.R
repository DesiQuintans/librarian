# Internal functions for librarian.

# Non-standard evaluation of dots with base R so that I don't need to import Rlang.
# If keep_user = FALSE, remove the Username/ component from GitHub "Username/Packagename".
nse_dots <- function(..., keep_user = FALSE) {
    dots <- eval(substitute(alist(...)))
    dots <- as.character(dots)
    
    if (keep_user == FALSE) {
        dots <- sub(".*?/", "", dots)
    }
    
    dots <- unique(dots)
    
    return(dots)
}


# Check installed packages. 
# If ... is empty, return a list of installed packages.
# If ... is not empty (has package names), return a named logical vector showing if the 
#        packages are installed or not.
list_library <- function(...) {
    installed_pkgs <- rownames(utils::installed.packages())
    
    if (...length() > 0) {
        packages <- nse_dots(..., keep_user = FALSE)
        status <- packages %in% installed_pkgs
        names(status) <- packages
        
        return(status)
    } else {
        return(installed_pkgs)
    }
}


# Check attached packages.
# If ... is empty, return a list of currently-attached packages.
# If ... is not empty (has package names), return a named logical vector showing if the 
#        packages are attached or not.
list_attached <- function(...) {
    attached <- (.packages())
    
    if (...length() > 0) {
        packages <- nse_dots(..., keep_user = FALSE)
        
        status <- packages %in% attached
        names(status) <- packages
        
        return(status)
    } else {
        return(attached)
    }
}
