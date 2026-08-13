# Name: g_vs_map
# Label: Vital Signs - Mean Arterial Pressure Over Time
#
# Exercise 3: Create two plots of MAP over time by treatment arm,
#             restricted to patients in the ">65" age group.
#
# Note: run ad_adsl.R then ad_advs.R first — AGEGR2 and the MAP / MAPV2
# parameters are added by those programs and saved to data/advs.RDS.

library(ggplot2)
library(dplyr)

# Load dataset ----
# advs already contains AGEGR2 (merged in from ADSL during Exercise 2)
load(file.path("data", "advs.RDS"))  # loads 'advs'

# Prepare data ----
# Keep only on-treatment visits for the oldest age group
advs_plot <- advs %>%
  filter(
    AGEGR2 == ">65",    # derived in Exercise 1a
    !is.na(AVISITN)     # on-treatment scheduled visits only
  )

# Exercise 3: Build the plots ----
# ---------------------------------------------------------------
# Create two line graphs, one for MAP and one for MAPV2:
#   - x-axis : visit number (AVISITN)
#   - y-axis : mean AVAL across subjects at each visit
#   - colour  : treatment arm (TRTA)
#
# Suggested steps:
#   1. Filter advs_plot to the relevant PARAMCD
#   2. group_by(AVISITN, AVISIT, TRTA) %>% summarise(mean_aval = mean(AVAL, na.rm = TRUE))
#   3. ggplot(aes(x = AVISITN, y = mean_aval, colour = TRTA, group = TRTA)) +
#        geom_line() + geom_point() + labs(...) + theme_bw()

# Plot 1: MAP (standard formula, Exercise 2a) ----
# YOUR CODE HERE

# Plot 2: MAPV2 (alternative formula, Exercise 2b) ----
# YOUR CODE HERE
