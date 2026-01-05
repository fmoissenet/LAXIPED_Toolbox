# ==============================================================================
# LAXIPED project
# Florent Moissenet
# Geneva University Hospitals
# 2025
# ==============================================================================

# Clear workspace
rm(list = ls())

# Select working directories
folder_inputs  <- "C:/Users/Florent/OneDrive - Université de Genève/_PROJETS/LAXIPED/WP1/Dataset/LAXIPED/Data/"
setwd(folder_inputs)

# Load requested libraries
library(rmcorr)

# Load data
df <- read.csv("CorrelationData_input.csv",header=TRUE,sep=",",dec=".")


df$Participant <- as.factor(df$Participant)

rmcorr(
  Participant,
  Measure1,
  Measure2,
  df,
  CI.level = 0.95,
  CIs = c("analytic", "bootstrap"),
  nreps = 100,
  bstrap.out = F
)