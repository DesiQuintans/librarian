
# Control printing to the console -----------------------------------------


#' Produce a nicely-wrapped paragraph for console printing
#'
#' Wrapping text needs to be done separately from actually printing it with 
#' `stop` or `warning` or `message`. This is because these functions typically
#' also print some information about the environment where they were called.
#'
#' @param ... Vectors to be coerced to Character.
#'
#' @return The text in `...` will be collapsed and wrapped.
#' 
#' @examples 
#' \dontrun{
#' wrapped <- 
#' wrap_text(
#'     "Lorem ipsum dolor sit amet, ornare justo condimentum",
#'     "et sit lorem! Himenaeos, vel et sodales sit.",
#'     "Eu nulla. Magna ullamcorper nascetur placerat platea.\n\n",
#'     "Eleifend semper velit sed aliquam, ut ligula non commodo.")
#' 
#' cat(wrapped)
#' 
#' #>  Lorem ipsum dolor sit amet, ornare justo condimentum et sit lorem! 
#' #>  Himenaeos, vel et sodales sit. Eu nulla. Magna ullamcorper 
#' #>  nascetur placerat platea. 
#' #>
#' #>  Eleifend semper velit sed aliquam, ut ligula non commodo.
#' }
#' 
#' @md
wrap_text <- function(...) {
    strwrap(paste(c(...), collapse = " "), 
            width = 70, indent = 2, exdent = 2, 
            prefix = "\n", simplify = TRUE)
}




# Strings -----------------------------------------------------------------

#' Messages for the user
#'
#' @param message (Character) An identifier string for a message.
#' @param ... (Dots) Data to pass into the message for `sprintf()`.
#'
#' @return A string.
#' 
#' @examples
#' \dontrun{
#' message(tell_user("not allowed to make path", "C:/fakefolder"))
#' }
#'
#' @md
tell_user <- function(message, ...) {
    # I want to have all of my errors/warnings/messages in one place so that I
    # can be sure that they are being displayed consistently, written in a
    # consistent voice, and don't clutter the functions. They're also more
    # tersely informative in this form:
    #
    # stop(tell_user("not allowed to make path", list_of_paths))
    #
    # compared to the real error message which is quite long. Having the
    # messages in a function also means that I can use the function directly in
    # tests, so the tests will not break if I change the text.
    
    format_msg <- function(msg, ..., wrap = TRUE) {
        text <- do.call(what = sprintf, 
                        args = c(fmt = msg, lapply(list(...), collapse_vec)))
        
        if (wrap == TRUE) {
            wrap_text(text)
        } else {
            return(text)
        }
    }
    
    text <- 
        switch(message,
               "not allowed to make path" = 
                   "These library paths do not exist, but 'make_path' is FALSE 
                    so lib_paths() is not allowed to create them: \n\n 
                    %s \n\n 
                    Set make_path = TRUE to create these paths.", 
               
               "cannot get user feedback in a non-interactive session" =
                   "These library paths do not exist, and they cannot be created 
                    if ask = TRUE in a non-interactive session:\n\n
                    %s \n\n
                    Set ask = FALSE to allow folder creation without prompting.",
               
               "lib paths were not created" =
                   "The requested library paths\n\n
                    %s \n\n
                    do not exist and were not created.",
               
               "ask to create path" =
                   return(format_msg(
                       "The requested library paths do not exist:\n\n%s\n\nCreate them?",
                       ..., wrap = FALSE)),  # askYesNo will not accept a vector of multiple strings.
               
               "paths not writeable" =
                   "The paths\n\n
                    %s \n\n
                    are not writeable.",
               
               "can't add uninstalled pkgs to .RProfile" =
                   "Some requested packages are not installed in the current 
                    library path:\n\n
                    %s \n\n
                    Use shelf() to install them, or if they are already 
                    installed, use the 'lib' argument to point to the folder they 
                    are installed in.",
               
               ".RProfile was edited" =
                   "Added library paths and startup packages to:\n
                   %s \n\n
                   Library paths:\n
                   %s \n\n
                   Startup packages:\n
                   %s", 
               
               "no packages were chosen" =
                   "No packages were requested.",
               
               "fixed cran repo placeholder" = 
                   "The 'cran_repo' argument in shelf() was not set, so it will 
                   use cran_repo = 'https://cran.r-project.org' by default.\n\n
                   To avoid this message, set the 'cran_repo' argument to a CRAN 
                   mirror URL (see https://cran.r-project.org/mirrors.html) or 
                   set 'quiet = TRUE'.",
               
               "invalid CRAN repo URL" =
                   "This is not a valid URL: cran_repo = %s\n
                   Defaulting to cran_repo = 'https://cran.r-project.org'.",
               
               "some packages failed to install" =
                   "These packages failed to install and were not attached:\n\n
                   %s \n\n
                   Check the spelling and capitalisation of the names.\n\n
                   Are they Bioconductor packages? If so, please install 
                   Bioconductor before running librarian::shelf().\n\n
                   Are they from GitHub? Please supply both the GitHub username 
                   and package name, e.g. DesiQuintans/librarian",
               
               "nothing to unshelf" =
                   "No packages were chosen for detaching. Either provide the 
                    names of packages, or set 'everything = TRUE' to detach all 
                    non-default packages.",
               
               "some packages still being used" =
                   "Some packages were not detached because other packages still 
                    need them:\n\n
                    %s \n\n
                    To force them to detach, use the 'safe = FALSE' argument.",
               
               "nothing to detach" = 
                   "The packages were not attached, so can't be detached.",
               
               "these packages will be installed" = 
                   "These packages will be installed:\n\n
                   %s \n\n
                   It may take some time.\n\n",
               
               stop("Invalid message name.")
        )
    
    format_msg(text, ..., wrap = TRUE)
}



#' Keep the first sentence of a string.
#'
#' @param string (Character) A string.
#'
#' @return The string with only the first sentence.
#'
#' @examples
#' \dontrun{
#' sentence("This is a sentence. And this is another sentence.")
#' 
#' #> [1] "This is a sentence."
#' 
#' sentence("This is just one sentence.")
#' 
#' #> [1] "This is just one sentence."
#' 
#' sentence("Is this a sentence? Or is this one. Maybe this one! What if there are lots of sentences?")
#' 
#' #> [1] "Is this a sentence?
#' }
#' 
#' @md
sentence <- function(string) {
    # Using gsub() was not reliable (it would return all but the last sentence
    # even though the regex was fine). That's why I use strsplit to get the
    # length of the first sentence and then get the string from that length.
    stc1 <- unlist(strsplit(string, "(\\.|!|\\?) [A-Z][a-z]"))[[1]]
    substr(string, 1, nchar(stc1) + 1)  # Get the punctuation character.
}
