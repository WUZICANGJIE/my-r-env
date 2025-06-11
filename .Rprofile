# R Profile Configuration
# Set library path to user directory
.libPaths("/home/wuzi/R/library")

# Activate renv
source("renv/activate.R")

# VSCode settings
if (interactive() && Sys.getenv("RSTUDIO") == "") {
  source(file.path(Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"), ".vscode-R", "init.R"))
}
