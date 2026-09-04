# Name: ADVS - Exercise 2 (MODEL SOLUTION)
# Label: Vital Signs Analysis Dataset

library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)
library(stringr)

# Load source datasets ----
vs   <- pharmaversesdtm::vs
load(file.path("data", "adsl.RDS"))  # loads 'adsl' built in Exercise 1

# Parameter lookup table ----
param_lookup <- tibble::tribble(
  ~VSTESTCD, ~PARAMCD,                            ~PARAM,
  "SYSBP",   "SYSBP",  "Systolic Blood Pressure (mmHg)",
  "DIABP",   "DIABP", "Diastolic Blood Pressure (mmHg)",
  "PULSE",   "PULSE",          "Pulse Rate (beats/min)",
  "MAP",      "MAP",    "Mean Arterial Pressure (mmHg)",
  "MAPV2",  "MAPV2",  "Mean Arterial Pressure V2 (mmHg)"
)

adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Build core ADVS dataset ----
advs <- vs %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars    = adsl_vars,
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = VSDTC
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT)) %>%
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars    = exprs(PARAMCD),
    by_vars     = exprs(VSTESTCD)
  ) %>%
  mutate(AVAL = VSSTRESN)

# Exercise 2a: Derive MAP ----
# Formula: MAP = (2 × DBP + SBP) / 3
advs <- advs %>%
  derive_param_map(
    by_vars       = exprs(STUDYID, USUBJID, !!!adsl_vars,
                          VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
    set_values_to = exprs(PARAMCD = "MAP"),
    get_unit_expr = VSSTRESU,
    filter        = VSSTAT != "NOT DONE" | is.na(VSSTAT)
  )

# Exercise 2b: Derive MAPV2 ----
# Formula: MAPV2 = (SBP + DBP) / 2  (arithmetic mean — illustrative alternative)
advs <- advs %>%
  derive_param_computed(
    by_vars       = exprs(STUDYID, USUBJID, !!!adsl_vars,
                          VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
    parameters    = c("SYSBP", "DIABP"),
    set_values_to = exprs(
      AVAL    = (AVAL.SYSBP + AVAL.DIABP) / 2,
      PARAMCD = "MAPV2"
    )
  )

# Add visit labels and treatment ----
advs <- advs %>%
  mutate(
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN|UNSCHED|RETRIEVAL|AMBUL") ~ NA_character_,
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),
    AVISITN = as.numeric(case_when(
      VISIT == "BASELINE" ~ "0",
      str_detect(VISIT, "WEEK") ~ str_trim(str_replace(VISIT, "WEEK", "")),
      TRUE ~ NA_character_
    )),
    TRTA = TRT01A,
    TRTP = TRT01P
  ) %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%
  derive_vars_merged(
    dataset_add = select(param_lookup, -VSTESTCD),
    by_vars     = exprs(PARAMCD)
  )

# Check results ----
advs %>% filter(PARAMCD %in% c("MAP", "MAPV2")) %>% count(PARAMCD)

# Save output ----
save(advs, file = file.path("data", "advs.RDS"), compress = "bzip2")
