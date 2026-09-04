# Name: ADVS - Exercise 2
# Label: Vital Signs Analysis Dataset
#
# Input: adsl (from Exercise 1), vs
#
# Exercises:
#   2a) Derive Mean Arterial Pressure (MAP) using admiral's built-in function
#   2b) Derive an alternative MAP (MAPV2) using a custom formula
#
# Note: run ad_adsl.R first so that data/adsl.RDS contains AGEGR2 and HISOBPFL.

library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)
library(stringr)

# Load source datasets ----
#
# VS — Vital Signs SDTM domain: one row per measurement per subject per timepoint.
#   Key variables used below:
#   VSTESTCD  - short code identifying what was measured
#               ("SYSBP" = systolic BP, "DIABP" = diastolic BP, "PULSE" = pulse rate)
#   VSSTRESN  - numeric result of the measurement (e.g. 118)
#   VSSTRESU  - unit of the measurement (e.g. "mmHg")
#   VSSTAT    - completion status: "NOT DONE" if the measurement was planned but
#               skipped; NA for normally collected records
#   VSDTC     - date/time of the measurement (character, ISO 8601 format)
#   VISIT     - visit name as recorded (e.g. "BASELINE", "WEEK 2")
#   VISITNUM  - numeric visit number
#   VSTPT     - timepoint description within a visit (e.g. "AFTER LYING DOWN")
#   VSTPTNUM  - numeric timepoint identifier (used to distinguish replicates)
vs   <- pharmaversesdtm::vs

# ADSL — built in Exercise 1; provides treatment dates and subject-level variables.
load(file.path("data", "adsl.RDS"))  # loads object named 'adsl'

# Quick look ----
glimpse(vs)

# Parameter lookup table ----
# Maps raw VSTESTCD codes to ADaM PARAMCD / PARAM labels.
# MAP and MAPV2 are derived parameters — not collected directly, but calculated.
# Note: VSTESTCD is the SDTM variable; PARAMCD is the ADaM equivalent.
param_lookup <- tibble::tribble(
  ~VSTESTCD, ~PARAMCD,                            ~PARAM,
  "SYSBP",   "SYSBP",  "Systolic Blood Pressure (mmHg)",
  "DIABP",   "DIABP", "Diastolic Blood Pressure (mmHg)",
  "PULSE",   "PULSE",          "Pulse Rate (beats/min)",
  "MAP",      "MAP",    "Mean Arterial Pressure (mmHg)",
  "MAPV2",  "MAPV2",  "Mean Arterial Pressure V2 (mmHg)"
)

# ADSL variables to carry into ADVS ----
# These treatment-related variables from ADSL are needed:
#   TRTSDT  - treatment start date (used to compute study day ADY)
#   TRTEDT  - treatment end date
#   TRT01A  - actual treatment arm for Period 1
#   TRT01P  - planned treatment arm for Period 1
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Build core ADVS dataset ----
# (This part is provided — read through it to understand the structure)
advs <- vs %>%

  # Merge treatment dates from ADSL onto every VS row.
  # We need TRTSDT to compute ADY (analysis day = days since first treatment).
  derive_vars_merged(
    dataset_add = adsl,
    new_vars    = adsl_vars,          # which ADSL columns to bring in
    by_vars     = exprs(STUDYID, USUBJID)  # join key
  ) %>%

  # Derive ADT (Analysis Date) from VSDTC (character date/time from VS).
  # new_vars_prefix = "A" creates the column ADT.
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = VSDTC     # source: character date of the VS measurement
  ) %>%

  # Derive ADY (Analysis Study Day): number of days from TRTSDT to ADT.
  # ADY = ADT - TRTSDT + 1  (day 1 = the day of first treatment).
  # Negative values indicate pre-treatment measurements (e.g. baseline visits).
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT)) %>%

  # Map VSTESTCD -> PARAMCD using the lookup table above.
  # PARAMCD is the ADaM standardised parameter code (replaces the raw VSTESTCD).
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars    = exprs(PARAMCD),     # only bring PARAMCD across here
    by_vars     = exprs(VSTESTCD)     # match on the raw test code
  ) %>%

  # Set AVAL (Analysis Value) = VSSTRESN (the raw numeric result).
  # AVAL is the primary numeric analysis variable in all BDS ADaM datasets.
  mutate(AVAL = VSSTRESN)


# Exercise 2a: Derive Mean Arterial Pressure (MAP) ----
# ---------------------------------------------------------------
# MAP = (2 × DBP + SBP) / 3
#
# Admiral provides a dedicated function for this: derive_param_map()
# It finds matching SBP and DBP rows (same subject, same timepoint) and creates
# a new MAP row for each pair.
#
# by_vars lists every column that identifies a unique timepoint — admiral uses
# these to match the SBP and DBP records that belong together.
#
# filter excludes rows where VSSTAT == "NOT DONE" (measurement was skipped and
# VSSTRESN is blank). The | is.na(VSSTAT) keeps ordinary records where VSSTAT
# was never populated.
#
# Hint — call structure:
#   derive_param_map(
#     by_vars       = exprs(STUDYID, USUBJID, !!!adsl_vars,
#                           VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
#     set_values_to = exprs(PARAMCD = "MAP"),  # label the new rows as MAP
#     get_unit_expr = VSSTRESU,                # carry the unit from the source rows
#     filter        = VSSTAT != "NOT DONE" | is.na(VSSTAT)
#   )

advs <- advs %>%
  # YOUR CODE HERE


# Exercise 2b: Derive alternative MAP (MAPV2) using a custom formula ----
# ---------------------------------------------------------------
# Use the arithmetic mean of SBP and DBP as a simplified illustrative example:
#   MAPV2 = (SBP + DBP) / 2
#
# derive_param_computed() handles any custom formula.
# Admiral "pivots wide" the rows listed in parameters so that you can reference
# their AVAL values directly in the formula:
#   AVAL.SYSBP  - the AVAL value from the row where PARAMCD == "SYSBP"
#   AVAL.DIABP  - the AVAL value from the row where PARAMCD == "DIABP"
#
# One new MAPV2 row is created for each timepoint where both values are present.
# PARAM (the label) is NOT set here — it is added later by the lookup merge.
#
# Hint — call structure:
#   derive_param_computed(
#     by_vars       = exprs(STUDYID, USUBJID, !!!adsl_vars,
#                           VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
#     parameters    = c("SYSBP", "DIABP"),  # which PARAMCDs to combine
#     set_values_to = exprs(
#       AVAL    = ...,      # your formula using AVAL.SYSBP and AVAL.DIABP
#       PARAMCD = "MAPV2"   # PARAM label is added by the lookup merge below
#     )
#   )

advs <- advs %>%
  # YOUR CODE HERE


# Add visit labels and treatment ----
# (Provided — used for plotting in Exercise 3)
advs <- advs %>%
  mutate(
    # AVISIT: cleaned visit label for analysis (screen/unscheduled visits set to NA)
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN|UNSCHED|RETRIEVAL|AMBUL") ~ NA_character_,
      !is.na(VISIT) ~ str_to_title(VISIT),  # e.g. "WEEK 2" -> "Week 2"
      TRUE ~ NA_character_
    ),
    # AVISITN: numeric version of AVISIT (BASELINE = 0, WEEK n = n)
    AVISITN = as.numeric(case_when(
      VISIT == "BASELINE" ~ "0",
      str_detect(VISIT, "WEEK") ~ str_trim(str_replace(VISIT, "WEEK", "")),
      TRUE ~ NA_character_
    )),
    TRTA = TRT01A,   # actual treatment arm (copy for BDS naming convention)
    TRTP = TRT01P    # planned treatment arm (copy for BDS naming convention)
  ) %>%

  # Merge all remaining ADSL variables onto ADVS (e.g. AGE, SEX, AGEGR2,
  # HISOBPFL). negate_vars(adsl_vars) selects everything in adsl EXCEPT the
  # four variables already merged earlier (TRTSDT, TRTEDT, TRT01A, TRT01P).
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%

  # Add PARAM (the human-readable parameter label) from the lookup table.
  # This sets PARAM for all rows including the MAP and MAPV2 rows created above.
  derive_vars_merged(
    dataset_add = select(param_lookup, -VSTESTCD),  # bring PARAMCD and PARAM
    by_vars     = exprs(PARAMCD)
  )

# Check: how many MAP and MAPV2 records were created?
advs %>% filter(PARAMCD %in% c("MAP", "MAPV2")) %>% count(PARAMCD)

# Save output ----
save(advs, file = file.path("data", "advs.RDS"), compress = "bzip2")
