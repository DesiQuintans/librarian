
# Processing 'dots' into package names ------------------------------------

#' How many items are in dots?
#'
#' @param ... (Dots)
#'
#' @return An integer
#'
#' @examples
#' \dontrun{
#' dots_length(package, names, here)
#' 
#' #> [1] 3
#' }
#' 
#' @md
dots_length <- function(...) {
    length(eval(substitute(alist(...))))
}



#' Did the user pass arguments inside dots?
#'
#' @param ... (Dots)
#'
#' @return `TRUE` (dots is empty) or `FALSE` (dots is not empty).
#'
#' @examples
#' \dontrun{
#' is_dots_empty(package, names, here)
#' 
#' #> [1] FALSE
#' }
#'
#' @md
dots_is_empty <- function(...) {
    dots_length(...) <= 0
}



#' Is the 1st 'dots' arg a character vector with length > 1?
#'
#' @param ... (Dots)
#'
#' @return `TRUE` if `..1` is a vector or list with length > 1.
#'
#' @examples
#' \dontrun{
#' dots1_is_pkglist()
#' 
#' #> [1] FALSE
#' 
#' dots1_is_pkglist("hello", "hey", "hi")
#' 
#' #> [1] FALSE
#' 
#' dots1_is_pkglist(c("hello", "hey"), "hi")
#' 
#' #> [1] TRUE
#' 
#' dots1_is_pkglist(c(hello, hey), "hi")
#' 
#' #> [1] FALSE
#' 
#' # A common programming scenario:
#' pkg_list <- c("only_one_package")
#' dots1_is_pkglist(pkg_list)
#' 
#' #> [1] TRUE
#' }
#' 
#' @md
dots1_is_pkglist <- function(...) {
    result <- tryCatch(eval(..1), 
                       error   = function(e) return(FALSE),
                       warning = function(w) return(FALSE))
    
    any(
        # A character vector with more than one element.
        (is.vector(result) & is.character(result) & length(result) > 1),
        # A character vector and no other items are provided in dots.
        (is.vector(result) & is.character(result) & dots_length(...) == 1)
    )
}



#' Convert dots to package names
#'
#' @param ... (Dots) Package names provided as bare names or strings (of length 1).
#'    If a character vector is provided as the first argument, it will be used
#'    and all other arguments in dots will be ignored.
#' @param keep_user (Logical) If `FALSE`, omit the username from a GitHub package reference.
#'
#' @return A character vector.
#'
#' @examples
#' \dontrun{
#' nse_dots(dplyr, DesiQuintans/desiderata, keep_user = FALSE)
#' 
#' #> [1] "dplyr"   "desiderata"
#' 
#' nse_dots(dplyr, DesiQuintans/desiderata, keep_user = TRUE)
#' 
#' #> [1] "dplyr"   "DesiQuintans/desiderata"
#' }
#' 
#' @md
nse_dots <- function(..., keep_user = FALSE) {
    if (dots_is_empty(...)) {
        return(character(0))
    }
    
    if (dots1_is_pkglist(...)) {
        # Accepting a character vector of package names makes Librarian's
        # functions more versatile for programming.
        dots <- ..1
    } else {
        dots <- as.character(eval(substitute(alist(...))))
    }
    
    dots <- gsub("\\s", "", dots)  # Closes https://github.com/DesiQuintans/librarian/issues/13
    
    if (keep_user == FALSE) {
        dots <- sub("^.*?/", "", dots)
    }
    
    dots <- unique(dots)
    dots <- dots[nchar(dots) > 0]
    
    return(dots)
}
