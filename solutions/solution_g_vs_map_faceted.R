# Name: g_vs_map_faceted (MODEL SOLUTION - OPTIONAL)
# Label: Vital Signs - Mean Arterial Pressure Over Time, faceted by HISOBPFL

library(ggplot2)
library(dplyr)

# Load dataset ----
load(file.path("data", "advs.rda"))  # loads 'advs'

# Prepare data ----
map_summary <- advs %>%
  filter(PARAMCD == "MAP" & AGEGR2 == "55-65" & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A, HISOBPFL) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

mapv2_summary <- advs %>%
  filter(PARAMCD == "MAPV2" & AGEGR2 == "55-65" & !is.na(AVISITN)) %>%
  group_by(AVISITN, AVISIT, TRT01A, HISOBPFL) %>%
  summarise(mean_aval = mean(AVAL, na.rm = TRUE), .groups = "drop")

facet_labels <- c(Y = "High SBP (>160 mmHg)", N = "No high SBP")

# Plot 1: MAP (standard formula), faceted by HISOBPFL ----
p1_facet <- ggplot(map_summary, aes(x = AVISITN, y = mean_aval, colour = TRT01A, group = TRT01A)) +
  geom_line() +
  geom_point(size = 2) +
  facet_wrap(~HISOBPFL, labeller = labeller(HISOBPFL = facet_labels)) +
  labs(
    title    = "Mean Arterial Pressure Over Time",
    subtitle = "Age group: 55-65 years, split by high SBP flag",
    x        = "Visit (week)",
    y        = "Mean MAP (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p1_facet)

# Plot 2: MAPV2 (alternative formula from Exercise 2a), faceted by HISOBPFL ----
p2_facet <- ggplot(mapv2_summary, aes(x = AVISITN, y = mean_aval, colour = TRT01A, group = TRT01A)) +
  geom_line() +
  geom_point(size = 2) +
  facet_wrap(~HISOBPFL, labeller = labeller(HISOBPFL = facet_labels)) +
  labs(
    title    = "Mean Arterial Pressure V2 Over Time",
    subtitle = "Age group: 55-65 years, split by high SBP flag",
    x        = "Visit (week)",
    y        = "Mean MAPV2 (mmHg)",
    colour   = "Treatment"
  ) +
  theme_bw()

print(p2_facet)

# Save faceted plots ----
ggsave(file.path("images", "solution_map_faceted.png"), p1_facet, width = 9, height = 5, dpi = 150)
ggsave(file.path("images", "solution_mapv2_faceted.png"), p2_facet, width = 9, height = 5, dpi = 150)
