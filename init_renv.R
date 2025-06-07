# Sample R script to initialize an R project with renv
# This script should be run locally to create the renv.lock file

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

# Initialize renv project
renv::init()

# Define packages
packages <- c(
  "tidyverse",
  "data.table"
)

# Install all CRAN packages

renv::install(packages)

# Install GitHub packages
github_packages <- c(
  "itamarcaspi/experimentdatar",
  "nx10/httpgd"
)

for (pkg in github_packages) {
  renv::install(pkg)
}

# Create snapshot (lockfile)
renv::settings$snapshot.type("all")
renv::snapshot()

print("renv initialization complete! renv.lock file created.")
