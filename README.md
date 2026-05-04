# Giovannelli Lab R Bootstrap package to get your fresh Ubuntu install ready for analysis

[![forthebadge](https://forthebadge.com/images/badges/powered-by-coffee.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/built-with-science.svg)](https://forthebadge.com)

[![forthebadge](https://forthebadge.com/images/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/0-percent-optimized.svg)](https://forthebadge.com)


[![giovannellilab](https://img.shields.io/badge/BY-Giovannelli_Lab-blue)](http://dgiovannelli.github.io)
[![made-with-Markdown](https://img.shields.io/badge/Coded%20in-R-red.svg)](https://www.r-project.org/)
[![giovannellilab](https://img.shields.io/badge/MADE_BY-Donato_Giovannelli-orange)](https://github.com/dgiovannelli)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

Minimal bootstrap repository for installing the common global R package stack used by the Giovannelli Lab. 

This repository is intended for a fresh machine or shared lab environment where the base R ecosystem needs to be installed once:

```bash
git clone https://github.com/giovannellilab/giovannellilab-r-bootstrap.git
cd giovannellilab-r-bootstrap
bash scripts/install_all.sh
```

It deliberately does not use Docker, `renv`, profiles, or a complex package manager. Individual research projects should use `renv` or another reproducibility mechanism inside their own project repositories. This bootstrap repository is for the shared global lab baseline. The package should take care of dependencies (see [Debugging installation problems](#debugging-installation-problems)) but it requires you to have [Mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html) (or equivalent) and [Jupyter](https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html) already installed.


## Content

- [Ubuntu/Debian Full Install](#ubuntudebian-full-install)
- [R-Only Install](#r-only-install)
- [Check Installation](#check-installation)
- [Debugging installation problems](#debugging-installation-problems)
- [Diagnose](#diagnose)
- [Package Lists](#package-lists)


## Ubuntu/Debian Full Install

On Ubuntu or Debian systems, install system libraries, R packages, and then verify the installation:

```bash
bash scripts/install_all.sh
```

This runs:

```bash
bash scripts/install_system_ubuntu.sh
Rscript install.R
Rscript check_install.R
```


## R-Only Install

If system libraries are already installed, install only the R packages:

```bash
Rscript install.R
```

Packages are read from:

- `packages/cran.txt`
- `packages/bioconductor.txt`
- `packages/github.txt`

Empty lines and lines starting with `#` are ignored.


## Check Installation

Verify that the listed CRAN and Bioconductor packages can be loaded:

```bash
Rscript check_install.R
```

The check prints an installed/missing table and exits with status 1 if anything is missing.


## Debugging installation problems

R package installation failures usually come from one of three causes:

1. **Missing Linux system libraries**: packages that compile native code may need `apt` libraries first. This is common for geospatial, graphics, SSL, XML, compression, HDF5, and NetCDF packages.
2. **Interrupted downloads, cache problems, or timeouts**: large installs can fail if a download is interrupted, a mirror is slow, or a cached package is incomplete.
3. **R/Bioconductor version mismatch**: Bioconductor packages are tied to specific R and Bioconductor releases. A package may fail if the local R version is too old or too new for the expected Bioconductor version.

Start with the basic diagnostics:

```bash
Rscript scripts/diagnose.R
Rscript check_install.R
```

Clean failed install locks and the `pak` cache before retrying:

```r
unlink(file.path(.libPaths(), "00LOCK*"), recursive = TRUE, force = TRUE)
pak::cache_clean()
```

If downloads are timing out, increase the R download timeout:

```r
options(timeout = 1200)
```

To test one failing CRAN package at a time:

```r
options(timeout = 1200)
pak::pkg_install("sf")
```

To test one failing Bioconductor package at a time:

```r
options(timeout = 1200)
BiocManager::install("phyloseq", ask = FALSE, update = TRUE)
```

To identify missing system libraries, read the last part of the compiler or configure error. Look for lines mentioning missing headers, missing shared libraries, or failed checks such as:

```text
fatal error: gdal.h: No such file or directory
configure: error: libudunits2.a not found
Package 'proj', required by 'virtual:world', not found
```

Then search for the matching Ubuntu/Debian development package and test it manually:

```bash
sudo apt-get update
sudo apt-get install -y libgdal-dev
Rscript install.R
```

You can also ask `pak` to show expected system requirements for the current package lists:

```bash
Rscript scripts/show_sysreqs.R
```

If a dependency is missing from this repository, report it as a GitHub issue. Include:

- OS version
- R version
- failing command
- failing package
- last 40-80 lines of the error
- whether installing an apt package fixed it
- suggested addition to `packages/system_apt.txt`

Example issue title:

```text
Missing apt dependency for sf on Ubuntu 24.04
```

Example issue body:

```text
OS version:
Ubuntu 24.04

R version:
R version 4.5.0

Failing command:
Rscript install.R

Failing package:
sf

Last 40-80 lines of the error:
configure: error: gdal-config not found or not executable
ERROR: configuration failed for package 'sf'

Manual fix tested:
sudo apt-get install -y libgdal-dev

Did the apt package fix it?
Yes

Suggested addition to packages/system_apt.txt:
libgdal-dev
```

After confirming the missing system dependency, add it to `packages/system_apt.txt`, keep the list one package per line, then commit the change:

```bash
git add packages/system_apt.txt
git commit -m "Add missing apt dependency for sf"

```

## Diagnose

Print R version, library paths, session information, Jupyter kernels, and key package availability:

```bash
Rscript scripts/diagnose.R
```


## Package Lists

Keep GitHub-only packages minimal. Prefer CRAN or Bioconductor packages when available. Add GitHub-only packages to `packages/github.txt` as `user/repository`.

System dependencies for Ubuntu/Debian are listed in `packages/system_apt.txt`.
