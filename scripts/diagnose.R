message("R version")
message(R.version.string)

message("")
message(".libPaths()")
print(.libPaths())

message("")
message("sessionInfo()")
print(sessionInfo())

message("")
message("Jupyter kernels")
jupyter <- Sys.which("jupyter")
if (nzchar(jupyter)) {
  status <- system2(jupyter, c("kernelspec", "list"))
  if (!identical(status, 0L)) {
    message("jupyter kernelspec list exited with status ", status)
  }
} else {
  message("jupyter not found on PATH")
}

message("")
message("Key package availability")
key_packages <- c("tidyverse", "vegan", "phyloseq", "DESeq2", "dada2", "sf", "terra", "IRkernel")
available <- vapply(key_packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))
print(
  data.frame(
    package = key_packages,
    status = ifelse(available, "available", "missing"),
    stringsAsFactors = FALSE
  ),
  row.names = FALSE
)
