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
load(file.path("data", "advs.rda"))  # loads 'advs'

# Prepare data ----
# Keep only on-treatment visits and the req
map_summary <- advs %>%
  filter(PARAMCD == "MAP" & AGEGR2 %in% c("55-65") & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

mapv2_summary <- advs %>%
  filter(PARAMCD == "MAPV2" & AGEGR2 %in% c("55-65") & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

# Exercise 3: Build the plots ----
# ---------------------------------------------------------------
# Create two line graphs, one for MAP and one for MAPV2:
#   - x-axis : visit number (AVISITN)
#   - y-axis : mean AVAL across subjects at each visit
#   - colour  : treatment arm (TRT01A)
#
# Suggested steps:
#   1. Filter advs_plot to the relevant PARAMCD
#   2. group_by(AVISITN, AVISIT, TRT01A) %>% summarise(mean_aval = mean(AVAL, na.rm = TRUE))
#   3. ggplot(aes(x = AVISITN, y = mean_aval, colour = TRT01A, group = TRT01A)) +
#        geom_line() + geom_point() + labs(...) + theme_bw()

# Plot 1: MAP (standard formula) ----
# YOUR CODE HERE

# Plot 2: MAPV2 (alternative formula, Exercise 2a) ----
# YOUR CODE HERE
