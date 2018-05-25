## Test environments

- win-builder R-devel
- Local Windows 7 64-bit install, R-devel (2018-05-23 r74775)
- Local Windows 7 64-bit install, R 3.5.0
- Local Windows 7 64-bit install, R 3.4.2


## R CMD check results

There were no ERRORs or WARNINGs or NOTEs for the 3 local R versions that I tested, 
including R-devel.

win-builder produced no ERRORs or WARNINGs.

win-builder produced 2 NOTEs:

    1. A spellcheck false-positive for "GitHub" in the TITLE.
    2. A warning that examples took >10 seconds to run. This is because 'librarian' is
       a package for download, installing, and attaching other packages, and the examples
       illustrate these tasks.


## Reverse dependencies

This is a new release, so there are no reverse dependencies.
