options(error = quote(q(save = "no", status = 1, runLast = FALSE))) # Ensure script exits on error

# Ensure pacman is installed and load it
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman", repos = "https://cran.rstudio.com/")
}
library(pacman)

# List of addon packages to install
addon_packages <- c(
  'wbstats',
  'skimr',
  'summarytools',
  'modelsummary',
  'psych',
  'broom',
  'coefplot',
  'estimatr',
  'readxl',
  'countrycode',
  'comtradr',
  'rsdmx',
  'quantmod',
  'stargazer',
  'lmtest',
  'forecast',
  'zoo',
  'moments',
  'car',
  'pracma',
  'kableExtra',
  'optionstrat',
  'gt',
  'fUnitRoots',
  'strucchange'
)

# Install addon CRAN packages using pacman
print("Installing addon CRAN packages using pacman...")
p_load(char = addon_packages, load = FALSE)

print("Addon R packages installed successfully or were already present.")
