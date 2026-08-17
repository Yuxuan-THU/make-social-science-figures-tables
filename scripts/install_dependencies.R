args <- commandArgs(trailingOnly = TRUE)
file_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/")
skill_dir <- dirname(dirname(script_path))

repos <- getOption("repos")
repos["CRAN"] <- "https://cloud.r-project.org"
options(repos = repos)

required <- c(
  "ggplot2", "patchwork", "ggrepel", "marginaleffects", "sf", "igraph",
  "ggraph", "svglite", "ragg", "modelsummary", "fixest", "jsonlite",
  "dplyr", "tidyr", "scales", "renv"
)
installed <- rownames(installed.packages())
if (!"renv" %in% installed) install.packages("renv", dependencies = NA)

if (!"--latest" %in% args) {
  lockfile <- file.path(skill_dir, "renv.lock")
  if (!file.exists(lockfile)) stop("renv.lock not found.", call. = FALSE)
  renv::restore(project = skill_dir, lockfile = lockfile, prompt = FALSE)
} else {
  installed <- rownames(installed.packages())
  missing <- setdiff(required, installed)
  if (length(missing)) install.packages(missing, dependencies = NA)
}
message("Available: ", paste(intersect(required, rownames(installed.packages())), collapse = ", "))
