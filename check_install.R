repo_root <- normalizePath(".", mustWork = TRUE)

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

cran_packages <- read_package_list(file.path(repo_root, "packages", "cran.txt"))
bioc_packages <- read_package_list(file.path(repo_root, "packages", "bioconductor.txt"))

packages <- unique(c(cran_packages, bioc_packages))
installed <- vapply(packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))

result <- data.frame(
  package = packages,
  status = ifelse(installed, "installed", "missing"),
  stringsAsFactors = FALSE
)

print(result, row.names = FALSE)

missing_packages <- result$package[result$status == "missing"]

if (length(missing_packages) > 0) {
  message("")
  message("Missing packages: ", paste(missing_packages, collapse = ", "))
  quit(status = 1, save = "no")
}

message("")
message("All listed CRAN and Bioconductor packages are available")
