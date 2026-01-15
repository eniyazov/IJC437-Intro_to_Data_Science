# ==========================================
# 04_make_all_outputs.R
# Master script: runs the whole pipeline
# ==========================================

source("code/01_data_cleaning.R")
source("code/02_rq1_pca_kmeans.R")
source("code/03_rq2_duration_energy.R")

cat("\nDONE. All outputs generated in outputs/figures and outputs/tables.\n")
