options(
  timeout = max(1000, getOption("timeout")),
  repos = c(CRAN = "https://cran.rstudio.com")
)

message("Starting Giovannelli Lab R bootstrap install")

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

install_cran_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing required installer package from CRAN: ", pkg)
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }

  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Failed to install required installer package: ", pkg, call. = FALSE)
  }
}

run_step <- function(label, expr) {
  message("")
  message("==> ", label)
  tryCatch(
    force(expr),
    error = function(e) {
      stop(label, " failed: ", conditionMessage(e), call. = FALSE)
    }
  )
}

install_cran_if_missing("pak")
install_cran_if_missing("BiocManager")

cran_packages <- read_package_list(file.path(repo_root, "packages", "cran.txt"))
bioc_packages <- read_package_list(file.path(repo_root, "packages", "bioconductor.txt"))
github_packages <- read_package_list(file.path(repo_root, "packages", "github.txt"))
system_packages <- read_package_list(file.path(repo_root, "packages", "system_apt.txt"))

if (identical(Sys.getenv("GIOVANNELLI_BOOTSTRAP_CI"), "true")) {
  message("CI smoke test mode enabled; skipping full package installation")
  message("CRAN packages listed: ", length(cran_packages))
  message("Bioconductor packages listed: ", length(bioc_packages))
  message("GitHub packages listed: ", length(github_packages))
  message("System packages listed: ", length(system_packages))
  quit(save = "no", status = 0)
}

if (length(cran_packages) > 0) {
  run_step(
    paste("Installing CRAN packages:", paste(cran_packages, collapse = ", ")),
    pak::pkg_install(cran_packages)
  )
} else {
  message("No CRAN packages listed")
}

if (length(bioc_packages) > 0) {
  run_step(
    paste("Installing Bioconductor packages:", paste(bioc_packages, collapse = ", ")),
    BiocManager::install(bioc_packages, ask = FALSE, update = TRUE)
  )
} else {
  message("No Bioconductor packages listed")
}

if (length(github_packages) > 0) {
  github_specs <- paste0("github::", github_packages)
  run_step(
    paste("Installing GitHub packages:", paste(github_specs, collapse = ", ")),
    pak::pkg_install(github_specs)
  )
} else {
  message("No GitHub packages listed")
}

if (requireNamespace("IRkernel", quietly = TRUE)) {
  if (nzchar(Sys.which("jupyter"))) {
    tryCatch(
      run_step(
        "Registering IRkernel",
        IRkernel::installspec(user = TRUE, name = "ir", displayname = "R")
      ),
      error = function(e) {
        warning(
          "IRkernel registration failed: ",
          conditionMessage(e),
          call. = FALSE
        )
      }
    )
  } else {
    message("Skipping IRkernel registration: jupyter command not found.")
  }
} else {
  message("IRkernel is not available; skipping kernel registration")
}

message("")
message("Giovannelli Lab R bootstrap install completed")
