options(error = quote(q(save = "no", status = 1, runLast = FALSE))) # Ensure script exits on error

# Ensure pacman is installed and load it
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman", repos = "https://cran.rstudio.com/")
}
library(pacman)

# List of essential packages to install
essential_packages <- c(
  'languageserver', 
  'devtools', 
  'tidyverse', 
  'rmarkdown', 
  'shiny', 
  'data.table', 
  'ggplot2'
)

# Install essential CRAN packages using pacman
print("Installing essential CRAN packages using pacman...")
p_load(char = essential_packages, load = FALSE)

print("Essential R packages installed successfully or were already present.")
