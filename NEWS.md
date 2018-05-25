# librarian 1.0.2

- FIX - Many documentation changes for CRAN submission.
- FIX - Import `utils` (a default package) for base R's package-handling functions. Omitting this caused warnings in R CMD CHECK.
- FIX - Bug in `unshelf()` that made it try to unload packages even if they were not loaded.
- ADD - `repo` argument for `shelf()`, which defaults to the RStudio CRAN mirror. Had to add this so that remote tests for CRAN would not fail. Use `repo = getOption("repos")` to use the CRAN mirror that is set in RStudio's settings.

# librarian 1.0.1

- REM - No longer imports `rlang`. Only imports `devtools` now.
- ADD - `shelf()` now returns `devtools::session_info()` invisibly so that you can print it.
- ADD - `NEWS.md` file to track changes to the package.
- ADD - info re. updating package dependencies.

# librarian 1.0.0

- Initial release. Includes `shelf()` and `unshelf()` in feature-complete form.
