# ==========================================
# 00_setup_packages.R
# Sets CRAN mirror + installs/loads packages
# ==========================================

options(repos = c(CRAN = "https://cloud.r-project.org"))

required_packages <- c(
  "tidyverse", "skimr", "naniar", "here",
  "factoextra", "cluster", "scales"
)

to_install <- required_packages[!required_packages %in% installed.packages()[, "Package"]]

if (length(to_install) > 0) {
  install.packages(to_install)
}

invisible(lapply(required_packages, library, character.only = TRUE))
