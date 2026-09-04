# Name: g_vs_map (MODEL SOLUTION)
# Label: Vital Signs - Mean Arterial Pressure Over Time

library(ggplot2)
library(dplyr)

# Load dataset ----
load(file.path("data", "advs.RDS"))

# Prepare data ----
advs_plot <- advs %>%
  filter(
    AGEGR2 == ">65",
    !is.na(AVISITN)
  )

# Plot 1: MAP (standard formula, Exercise 2a) ----
map_summary <- advs_plot %>%
  filter(PARAMCD == "MAP") %>%
  group_by(AVISITN, AVISIT, TRTA) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

p1 <- ggplot(map_summary, aes(x = AVISITN, y = mean_aval, colour = TRTA, group = TRTA)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    title    = "Mean Arterial Pressure Over Time",
    subtitle = "Age group: >65 years",
    x        = "Visit (week)",
    y        = "Mean MAP (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p1)

# Plot 2: MAPV2 (alternative formula, Exercise 2b) ----
mapv2_summary <- advs_plot %>%
  filter(PARAMCD == "MAPV2") %>%
  group_by(AVISITN, AVISIT, TRTA) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

p2 <- ggplot(mapv2_summary, aes(x = AVISITN, y = mean_aval, colour = TRTA, group = TRTA)) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    title    = "Mean Arterial Pressure V2 Over Time",
    subtitle = "Age group: >65 years",
    x        = "Visit (week)",
    y        = "Mean MAPV2 (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p2)
