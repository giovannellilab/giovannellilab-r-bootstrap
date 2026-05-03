`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

script_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1] %||% "scripts/show_sysreqs.R")
repo_root <- normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)

read_package_list <- function(path) {
  if (!file.exists(path)) {
    stop("Package list not found: ", path, call. = FALSE)
  }

  lines <- readLines(path, warn = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  lines <- lines[!startsWith(lines, "#")]
  unique(lines)
}

if (!requireNamespace("pak", quietly = TRUE)) {
  message("Installing pak from CRAN")
  install.packages("pak", repos = "https://cloud.r-project.org")
}

if (!requireNamespace("pak", quietly = TRUE)) {
  stop("Failed to install pak", call. = FALSE)
}

cran_packages <- read_package_list(file.path(repo_root, "packages", "cran.txt"))
bioc_packages <- read_package_list(file.path(repo_root, "packages", "bioconductor.txt"))
github_packages <- read_package_list(file.path(repo_root, "packages", "github.txt"))
github_specs <- if (length(github_packages) > 0) paste0("github::", github_packages) else character()

packages <- unique(c(cran_packages, bioc_packages, github_specs))

if (length(packages) == 0) {
  message("No packages listed")
  quit(status = 0, save = "no")
}

pak::pkg_sysreqs(packages)
