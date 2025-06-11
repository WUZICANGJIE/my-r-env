# Sample R script to initialize an R project with renv
# This script creates the renv.lock file for VSCode.

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

# Initialize renv project
renv::init()

# Define packages
packages <- c(
  "tidyverse",
  "languageserver"
)

# Install all CRAN packages

renv::install(packages)

# Install GitHub packages
github_packages <- c(
  "nx10/httpgd"
)

for (pkg in github_packages) {
  renv::install(pkg)
}

# Create snapshot (lockfile)
renv::settings$snapshot.type("all")
renv::snapshot()

print("renv initialization complete! renv.lock file created.")
