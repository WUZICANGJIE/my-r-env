# Initialize renv and install all required packages
# This script should be run locally to create the renv.lock file

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

# Initialize renv project
renv::init()

# Essential packages
essential_packages <- c(
  'languageserver', 
  'devtools', 
  'tidyverse', 
  'rmarkdown', 
  'shiny', 
  'data.table', 
  'ggplot2'
)

# Addon packages
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

# Install all CRAN packages
all_cran_packages <- c(essential_packages, addon_packages)
renv::install(all_cran_packages)

# Install GitHub packages
github_packages <- c(
  "itamarcaspi/experimentdatar",
  "nx10/httpgd"
)

for (pkg in github_packages) {
  renv::install(pkg)
}

# Create snapshot (lockfile)
renv::snapshot()

print("renv initialization complete! renv.lock file created.")
print("You can now use this project with Docker.")
