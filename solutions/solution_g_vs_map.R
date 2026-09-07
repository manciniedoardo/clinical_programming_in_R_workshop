# Name: g_vs_map (MODEL SOLUTION)
# Label: Vital Signs - Mean Arterial Pressure Over Time

library(ggplot2)
library(dplyr)

# Load dataset ----
load(file.path("data", "advs.rda"))

# Prepare data ----
map_summary <- advs %>%
  filter(PARAMCD == "MAP" & AGEGR2 %in% c("55-65") & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

mapv2_summary <- advs %>%
  filter(PARAMCD == "MAPV2" & AGEGR2 %in% c("55-65") & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

# Plot 1: MAP (standard formula) ----
map_summary <- advs %>%
  filter(PARAMCD == "MAP" & AGEGR2 %in% c("55-65") & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

p1 <- ggplot(map_summary, aes(x = AVISITN, y = mean_aval, colour = TRT01A, group = TRT01A)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    title    = "Mean Arterial Pressure Over Time",
    subtitle = "Age group:55-65 years",
    x        = "Visit (week)",
    y        = "Mean MAP (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p1)

# Plot 2: MAPV2 (alternative formula from Exercise 2a) ----
mapv2_summary <- advs_plot %>%
  filter(PARAMCD == "MAPV2") %>%
  group_by(AVISITN, AVISIT, TRT01A) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

p2 <- ggplot(mapv2_summary, aes(x = AVISITN, y = mean_aval, colour = TRT01A, group = TRT01A)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    title    = "Mean Arterial Pressure V2 Over Time",
    subtitle = "Age group:55-65 years",
    x        = "Visit (week)",
    y        = "Mean MAPV2 (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p2)
