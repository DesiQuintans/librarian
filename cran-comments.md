## Resubmission

This is a resubmission. I have made these changes based on your feedback:

    - Added a lib argument to shelf() so that users can define a library folder.
    - Added lib_paths(), which wraps .libPaths() and offers automatic folder creation.
    - Wrapped examples in \donttest{} instead of commenting them out.
    - Removed function names from DESCRIPTION field.

Other comments:

    - You suggested that maybe the 'lib' arg could be passed through install_github() down 
      to install.packages(), but unfortunately not.

## Test environments

- win-builder R-devel
- win-builder R-current (3.5.0)
- Local Windows 7 64-bit install, R 3.5.0


## R CMD check results

There were no ERRORs or WARNINGs or NOTEs for the local R version that I tested.

win-builder (R-devel and R 3.5.0) produced no ERRORs or WARNINGs.

win-builder produced 1 NOTE ("checking CRAN incoming feasibility").


## Reverse dependencies

This is a new release, so there are no reverse dependencies.
