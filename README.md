# Giovannelli Lab R Bootstrap

Minimal bootstrap repository for installing the common global R package stack used by the Giovannelli Lab.

This repository is intended for a fresh machine or shared lab environment where the base R ecosystem needs to be installed once:

```bash
git clone https://github.com/giovannellilab/giovannellilab-r-bootstrap.git
cd giovannellilab-r-bootstrap
bash scripts/install_all.sh
```

It deliberately does not use Docker, `renv`, profiles, or a complex package manager. Individual research projects should use `renv` or another reproducibility mechanism inside their own project repositories. This bootstrap repository is for the shared global lab baseline.

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

## Diagnose

Print R version, library paths, session information, Jupyter kernels, and key package availability:

```bash
Rscript scripts/diagnose.R
```

## Package Lists

Keep GitHub-only packages minimal. Prefer CRAN or Bioconductor packages when available. Add GitHub-only packages to `packages/github.txt` as `user/repository`.

System dependencies for Ubuntu/Debian are listed in `packages/system_apt.txt`.
