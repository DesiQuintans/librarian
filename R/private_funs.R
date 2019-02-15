# Internal functions for librarian.


#' Non-standard evaluation of dots with base R
#'
#' @param ... (Dots) A dots list.
#' @param keep_user (Logical) If `FALSE`, remove the Username/ component from GitHub 
#'     "Username/Packagename".
#'
#' @return The dots list as a character vector.
#'
#' @examples
#' \dontrun{
#' nse_dots(package, names, here)
#' 
#' #> [1] "package" "names"   "here"   
#' }
#' 
#' @md
nse_dots <- function(..., keep_user = FALSE) {
    dots <- eval(substitute(alist(...)))
    dots <- as.character(dots)
    
    if (keep_user == FALSE) {
        dots <- sub(".*?/", "", dots)
    }
    
    dots <- unique(dots)
    
    return(dots)
}


#' Check installed packages
#'
#' This function behaves differently to the publicly-exposed librarian functions; because
#' it is meant to be used inside librarian functions, it takes package names as a 
#' character vector instead of as bare names. That's why I don't export it.
#'
#' @param packages (NULL or Character) 
#'
#' @return If `packages = NULL`, return a character vector of installed packages. If 
#'     `packages` contains a character vector of package names, return a named logical 
#'     vector showing if the packages are installed or not.
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
#' }
#' 
#' @md
check_installed <- function(packages = NULL) {
    if (is.null(packages)) {
        return(rownames(utils::installed.packages()))  # Very slow!
    } else {
        found_pkgs <- find.package(packages, quiet = TRUE)
        # Last directory of find.package() output is package folder.
        found_pkg_names <- gsub("^.*?(/|\\\\)(.*?)$", "\\2", found_pkgs)
        status <- packages %in% found_pkg_names
        names(status) <- packages
        
        return(status)
    }
}



#' Check attached packages
#'
#' This function behaves differently to the publicly-exposed librarian functions; because
#' it is meant to be used inside librarian functions, it takes package names as a 
#' character vector instead of as bare names. That's why I don't export it.
#'
#' @param packages (NULL or Character)
#'
#' @return If `packages = NULL`, return a list of currently-attached packages. If 
#'     `packages` contains a character vector of package names, return a named logical 
#'     vector showing if the packages are attached or not.
#'
#' @examples
#' \dontrun{
#' check_attached()
#' 
#' #> [1] "stats"  "graphics"  "grDevices"  ...
#' 
#' check_attached(c("utils", "stats"))
#' 
#' #> utils stats 
#' #> TRUE  TRUE 
#' }
#' 
#' @md
check_attached <- function(packages = NULL) {
    attached <- (.packages())
    
    if (is.null(packages)) {
        return(attached)
    } else {
        status <- packages %in% attached
        names(status) <- packages
        
        return(status)
    }
}

#' Build a path, creating subfolders if needed
#'
#' Whereas `base::file.path()` only concatenates strings to build a path, `make_dirs()`
#' *also* makes sure those folders exist.
#'
#' @param ... (Character) Arguments to send to `file.path()`. You can provide a complete
#'    path as a single string, or incrementally build a path with many strings.
#'
#' @return (Character) A file path. Automatically adds trailing slashes if required.
#'
#' @examples
#' \dontrun{
#' make_dirs(tempdir(), "newfolder")
#'
#' #> [1] "C:/Users/.../Temp/RtmpSwZA8X/newfolder"
#' }
#'
#' @section Authors:
#' - Desi Quintans (<http://www.desiquintans.com>)
#'
#' @section Source:
#' - Desiderata package (<https://github.com/DesiQuintans/desiderata>)
#'
#' @md
make_dirs <- function(...) {
    path <- file.path(...)
    
    if (grepl("\\.", basename(path)) == TRUE) {
        pathToBuild <- file.path(dirname(path), "/")
        # The basename has a file extension, which means that it ends with a filename.
        # Therefore dirname() is returning a folder path without the trailing slash.
        # Add the trailing slash or else dir.create() will not create the last folder.
    } else if (substr(path, nchar(path), nchar(path)) == "/") {
        pathToBuild <- path
        # The last character in the path is a slash, therefore this is a fully-qualified folder
        # path. I can create it as-is.
    } else {
        pathToBuild <- file.path(path, "/")
        # If path does not have a file extension and doesn't have a trailing slash, then it is
        # a folder path with no trailing slash -- but we can't use the above code because
        # dirname() cuts off the last folder in this case.
    }
    
    if (!dir.exists(pathToBuild))
        dir.create(pathToBuild, recursive = TRUE)
    
    return(normalizePath(path, winslash = "/"))
}



#' Suppress "lib unspecified" message
#' 
#' This is used to suppress a specific warning message that is printed by install.packages()
#' and remove.packages(), which is caused by the 'lib' arg not being assigned in the 
#' function call.
#'
#' @param expr (Expression) A function call.
#'
#' @return Runs the expression, suppressing the "(as 'lib' is unspecified)" message only.
#' 
#' @examples
#' \dontrun{
#' suppress_lib_message(remove.packages(fortunes))
#' }
suppress_lib_message <- function(expr) {
    regex = "\\(as .lib. is unspecified\\)"
    
    withCallingHandlers(expr, message = function(w) {
        if (length(regex) == 1 && length(grep(regex, conditionMessage(w)))) {
            invokeRestart("muffleMessage")
        }
    })
}



#' Collapse a vector 
#'
#' I use this internally for turning a vector of package names into a string.
#'
#' @param ... (...) Vectors that will be concatenated and coerced to Character.
#' @param wrap (Character) Placed at the left and right sides of each vector element.
#' @param collapse (Character) Placed between each element of the original vector(s).
#' @param unique (Logical) If `TRUE`, duplicate entries in `...` will be removed.
#'
#' @return A string.
#'
#' @examples
#' \dontrun{
#' collapse_vec(month.abb)
#' #> [1] "'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'"
#' }
#' 
#' @md
collapse_vec <- function(..., wrap = "'", collapse = ", ", unique = TRUE) {
    vec <- as.character(c(...))

    if (unique == TRUE) {
        vec <- unique(vec)
    }

    # vec is wrapped in empty strings so that 'sep' arg will wrap each entry.
    paste(character(0), vec, character(0), collapse = collapse, sep = wrap)  
}



# Runs with devtools::release().
release_questions <- function() {
    c(
        "Have you run devtools::test()?"
    )
}
