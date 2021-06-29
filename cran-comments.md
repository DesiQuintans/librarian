
## Test environments

- Local Windows 7 64-bit install, R 4.1.0
- win-builder R-devel
- win-builder R-current
- R-hub (Windows Server 2008 R2 SP1, R-devel)
- R-hub (Ubuntu Linux 16.04 LTS, R-release)


## R CMD check results

There were no ERRORs or WARNINGs or NOTEs for the local R version that I tested.

There were no ERRORs or WARNINGs or NOTEs for win-builder (R-devel and R 4.1.0).

R-hub produced one error because it ran a \donttest code example: 

    > Error: Bioconductor does not yet build and check packages for R version 4.2; 
      see https://bioconductor.org/install

## Reverse dependencies

None.
