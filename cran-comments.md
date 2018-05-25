## Test environments

- win-builder R-devel
- Local Windows 7 64-bit install, R-devel (2018-05-23 r74775)
- Local Windows 7 64-bit install, R 3.5.0
- Local Windows 7 64-bit install, R 3.4.2


## R CMD check results

There were no ERRORs or WARNINGs or NOTEs for the 3 local R versions that I tested, 
including R-devel.

win-builder produced 2 identical ERRORs in 2 calls related to utils::install.packages:

   > Error in contrib.url(repos, "source") : 
   >   trying to use CRAN without setting a mirror
   > Calls: shelf -> <Anonymous> -> contrib.url

This might be caused by install.packages(..., repos = getOption("repos")) not resolving
to a CRAN mirror on the remote machine. This is the default value for this argument.


## Reverse dependencies

This is a new release, so there are no reverse dependencies.
