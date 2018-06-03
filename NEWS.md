# librarian 1.0.3

- ADD - `unshelf()` can handle the Github Username/packagename format now, instead of requiring the user to provide only the package name. The biggest effect of this change is that if you want to unload your packages, you can now just change your `shelf()` to `unshelf()` and run it.
- ADD - `shelf()` and `unshelf()` check for duplicates in the package list you provide.

# librarian 1.0.2

- FIX - Many documentation changes for CRAN submission.
- FIX - Import `utils` (a default package) for base R's package-handling functions. Omitting this caused warnings in R CMD CHECK.
- FIX - Bug in `unshelf()` that made it try to unload packages even if they were not loaded.
- ADD - `custom_repo` argument for `shelf()`, which defaults to R's default behaviour.

# librarian 1.0.1

- REM - No longer imports `rlang`. Only imports `devtools` now.
- ADD - `shelf()` now returns `devtools::session_info()` invisibly so that you can print it.
- ADD - `NEWS.md` file to track changes to the package.
- ADD - info re. updating package dependencies.

# librarian 1.0.0

- Initial release. Includes `shelf()` and `unshelf()` in feature-complete form.
