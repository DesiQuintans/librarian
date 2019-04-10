
# Internal programming functions ------------------------------------------

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
    
    # mustWork = FALSE because terminal folder names that contain a . are interpreted as
    # references to files with an extension, and R tries to ensure that those files exist.
    # For example: C:/MyPath/R/Library/3.5
    # See https://github.com/DesiQuintans/librarian/issues/21
    return(normalizePath(path, winslash = "/", mustWork = FALSE))
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



#' Turn a list of words into a fuzzy regex
#' 
#' A fuzzy regex is one that will match search terms in any order by using PERL 
#' lookaround. This is very slow, but often worth the cost to get more complete
#' results.
#'
#' @param vec (Character) A string containing space-separated keywords to search for.
#'
#' @return A string where each word has been wrapped as a lookaround term.
#'
#' @examples
#' \dontrun{
#' fuzzy_needle("network centrality")
#' #> [1] "(?=.*network)(?=.*centrality)"
#' }
fuzzy_needle <- function(vec) {
    words <- unique(unlist(strsplit(vec, "\\s+")))
    
    groups <- sapply(words, function(x) paste0("(?=.*", x, ")"), USE.NAMES = FALSE)
    
    paste0(groups, collapse = "")
}



#' Assert that a URL is complete and valid
#'
#' @details The regex I use is "@stephenhay" from 
#' <https://mathiasbynens.be/demo/url-regex> because it's the shortest regex that 
#' matches every CRAN mirror at <https://cran.r-project.org/mirrors.html>.
#'
#' @param string (Character) A URL to check.
#'
#' @return A logical value, `TRUE` if the URL is valid, `FALSE` if otherwise.
#'
#' @examples
#' \dontrun{
#' is_valid_url("http://rstudio.com")
#' }
#' 
#' @md
is_valid_url <- function(string) {
    any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", string))
}



#' Suppresses console output, including printing
#'
#' This is copied from my personal package, `desiderata`.
#'
#' @param expr (Expression) An expression to evaluate.
#' 
#' @return Evaluates `expr`.
#' 
#' @md
shhh <- function(expr) {
    call <- quote(expr)
    
    invisible(
        utils::capture.output(
            out <- 
                suppressWarnings(
                    suppressMessages(
                        suppressPackageStartupMessages(
                            eval(call)))))
    )
    return(invisible(out))
}


# Convenience operators --------------------------------------------------------

"%notin%" <- function(x, y) {
    !(match(x, y, nomatch = 0) > 0)
}



# Runs with devtools::release() ------------------------------------------------

release_questions <- function() {
    c(
        "Have you run devtools::test()?"
    )
}
