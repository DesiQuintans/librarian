% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_pkg_status.R
\name{check_pkg_status}
\alias{check_pkg_status}
\title{Check if packages are installed or attached}
\usage{
check_pkg_status(..., status, use_list = FALSE)
}
\arguments{
\item{...}{(Dots) Package names as bare names, strings, or a vector of strings.
If left blank, returns a list of all packages that are installed/attached
depending on the value of \code{status}.}

\item{status}{(Character) \code{"installed"} checks if packages are installed.
\code{"attached"} checks if packages are currently attached.}

\item{use_list}{(Logical) If \code{TRUE}, a character vector of package names was
passed in \code{..1}, so use that as the results list. This is for programming
use; \code{nse_dots()} already detects if a char vector of length > 1 is in
\code{..1} and uses it as the package list automatically, but it does not do
that for char vectors of length 1 because the user can offer a mix of names
and strings to \code{...} as a convenience.}
}
\value{
If \code{dots} is empty, a character vector of package names. Otherwise,
return a named logical vector where \code{TRUE} means the package is installed
or attached, depending on the value of \code{status}.
}
\description{
Check if packages are installed or attached
}
