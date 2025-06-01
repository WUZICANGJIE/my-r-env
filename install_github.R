options(error = quote(q(save = "no", status = 1, runLast = FALSE))) # Ensure script exits on error

# Ensure pacman is installed and load it
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman", repos = "https://cran.rstudio.com/")
}
library(pacman)

# Ensure devtools is installed and loaded using pacman
# devtools should ideally be installed by install_essentials.R
# If running this script standalone, this line ensures devtools is available.
p_load(char = "devtools")

# List of packages to install from GitHub
github_packages_to_install <- c(
  "itamarcaspi/experimentdatar",
  "nx10/httpgd"
  # Add other GitHub packages here, e.g., "username/repository"
)

# Install packages from GitHub
print("Installing packages from GitHub...")
for (gh_pkg in github_packages_to_install) {
  print(paste("Installing", gh_pkg, "from GitHub..."))
  # Ensure devtools is loaded for install_github
  if (!requireNamespace("devtools", quietly = TRUE)) {
      stop("devtools package is required to install GitHub packages but is not installed.")
  }
  devtools::install_github(gh_pkg)
  
  # Extract package name from "username/repository"
  pkg_name <- sub(".*/", "", gh_pkg)
  if (!requireNamespace(pkg_name, quietly = TRUE)) {
    stop(paste("Failed to install package:", gh_pkg, "(", pkg_name, ")"))
  } else {
    print(paste("Successfully installed", gh_pkg, "(", pkg_name, ")"))
  }
}
print("Specified GitHub packages installed successfully or were already present.")
