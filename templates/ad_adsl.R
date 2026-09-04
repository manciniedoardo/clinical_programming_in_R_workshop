# Name: ADSL - Exercise 1
# Label: Subject Level Analysis Dataset
#
# Input: dm, ex, vs
#
# Exercises:
#   1a) Derive a new age group variable (AGEGR2)
#   1b) Derive a high systolic blood pressure flag (HISOBPFL)

library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)
library(stringr)

# Load source datasets ----
#
# DM — Demographics domain: one row per subject
#   Key variables used below:
#   STUDYID  - study identifier (links all datasets together)
#   USUBJID  - unique subject identifier (primary key across all datasets)
#   ARM      - planned treatment arm as randomised (e.g. "Xanomeline High Dose")
#   ACTARM   - actual treatment arm received (may differ from ARM)
#   AGE      - age at study start, in years
dm <- pharmaversesdtm::dm

# EX — Exposure domain: one row per dosing record per subject
#   Key variables used below:
#   EXDOSE   - dose amount given (0 for placebo records)
#   EXTRT    - treatment name (e.g. "Xanomeline High Dose", "PLACEBO")
#   EXSTDTC  - dose start date/time (character, ISO 8601 format e.g. "2014-01-02")
#   EXENDTC  - dose end date/time (character, ISO 8601 format)
#   EXSEQ    - sequence number: orders multiple exposure records per subject
ex <- pharmaversesdtm::ex

# VS — Vital Signs domain: one row per measurement per subject per timepoint
#   Used in Exercise 1b to identify patients with high blood pressure.
#   Key variables used below:
#   VSTESTCD  - short code for the test (e.g. "SYSBP", "DIABP", "PULSE")
#   VSSTRESN  - numeric result of the measurement (e.g. 118)
vs <- pharmaversesdtm::vs

# Derivations ----

# derive_vars_dtm() converts a character date/time column to a numeric datetime.
# We do this for the start and end of each exposure record so we can then find
# the first dose date (TRTSDT) and last dose date (TRTEDT) per subject.
#
# new_vars_prefix = "EXST" creates two new columns:
#   EXSTDTM  - start datetime (numeric POSIXct)
#   EXSTTMF  - start time imputation flag (records whether the time was imputed)
#
# new_vars_prefix = "EXEN" creates:
#   EXENDTM  - end datetime (numeric POSIXct)
#   EXENTMF  - end time imputation flag
ex_ext <- ex %>%
  derive_vars_dtm(
    dtc             = EXSTDTC,  # source: character start date/time from EX
    new_vars_prefix = "EXST"
  ) %>%
  derive_vars_dtm(
    dtc             = EXENDTC,  # source: character end date/time from EX
    new_vars_prefix = "EXEN",
    time_imputation = "last"    # when time is missing, impute to 23:59:59
  )

adsl <- dm %>%

  ## Derive treatment arm variables ----
  # TRT01P - Planned treatment arm for Period 1 (copy of ARM)
  # TRT01A - Actual treatment arm for Period 1 (copy of ACTARM)
  mutate(TRT01P = ARM, TRT01A = ACTARM) %>%

  ## Derive treatment start datetime / date ----
  # Finds the earliest exposure record with a positive dose (or placebo) and
  # merges its start datetime onto ADSL.
  # filter_add keeps only genuine dosing records (dose > 0, or dose = 0 but
  # treatment name contains "PLACEBO").
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add  = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
                   !is.na(EXSTDTM),
    new_vars    = exprs(
      TRTSDTM = EXSTDTM,  # Treatment start datetime
      TRTSTMF = EXSTTMF   # Treatment start time imputation flag
    ),
    order       = exprs(EXSTDTM, EXSEQ),  # order to pick the "first" record
    mode        = "first",                # keep only the earliest record
    by_vars     = exprs(STUDYID, USUBJID) # one result per subject
  ) %>%

  ## Derive treatment end datetime / date ----
  # Same logic, but picks the LAST exposure record to get the final dose date.
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add  = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
                   !is.na(EXENDTM),
    new_vars    = exprs(
      TRTEDTM = EXENDTM,  # Treatment end datetime
      TRTETMF = EXENTMF   # Treatment end time imputation flag
    ),
    order       = exprs(EXENDTM, EXSEQ),
    mode        = "last",
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%

  ## Convert datetime to date, then derive duration ----
  # derive_vars_dtm_to_dt() strips the time portion:
  #   TRTSDTM -> TRTSDT  (treatment start date)
  #   TRTEDTM -> TRTEDT  (treatment end date)
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>%
  # derive_var_trtdurd() computes:
  #   TRTDURD = TRTEDT - TRTSDT + 1  (treatment duration in days)
  derive_var_trtdurd() %>%

  ## Safety population flag ----
  # SAFFL = "Y" if the subject received any study drug, else "N".
  # The safety population is the standard analysis population for safety analyses.
  derive_var_merged_exist_flag(
    dataset_add   = ex,
    by_vars       = exprs(STUDYID, USUBJID),
    new_var       = SAFFL,         # new flag variable
    condition     = EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO")),
    false_value   = "N",           # subject has EX records but none meet condition
    missing_value = "N"            # subject has no EX records at all
  ) %>%
  ## Grouping variables ----
  mutate(
    AGEGR1 = case_when(
      AGE < 18             ~ "<18",
      between(AGE, 18, 64) ~ "18-64",
      AGE > 64             ~ ">64",
      TRUE                 ~ NA_character_
    )
  )

# Exercise 1a: Derive a new age group variable (AGEGR2) ----
# ---------------------------------------------------------------
# Create AGEGR2 with the following groups:
#   AGE < 55          -> "<55"
#   55 <= AGE <= 65   -> "55-65"
#   AGE > 65          -> ">65"
#
# AGE is already in the dataset (from DM).
# Hint: follow the format_agegr1() pattern above using mutate() and case_when()
# between(x, lo, hi) is TRUE when lo <= x <= hi

adsl <- adsl # %>%
# add AGEGR2 code here

# Exercise 1b: Derive high systolic BP flag (HISOBPFL) ----
# ---------------------------------------------------------------
# Flag patients who have at least one systolic BP measurement > 160 mmHg.
#   HISOBPFL = "Y" if any SYSBP > 160 mmHg, else "N"
#
# Useful VS columns (already loaded above):
#   VSTESTCD  - vital signs test code: "SYSBP" = systolic blood pressure
#   VSSTRESN  - the numeric measurement value (e.g. 165)
#   STUDYID, USUBJID - links each VS record back to the subject in ADSL
#
# derive_var_merged_exist_flag() checks a condition in another dataset
# and merges the result back as a Y/N flag. It sets new_var = "Y" for any
# subject where at least one row in dataset_add satisfies condition.
#
# Hint:
#   derive_var_merged_exist_flag(
#     dataset_add   = vs,
#     by_vars       = exprs(STUDYID, USUBJID),
#     new_var       = HISOBPFL,
#     condition     = VSTESTCD == "SYSBP" & VSSTRESN > 160,
#     false_value   = "N",
#     missing_value = "N"
#   )

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add   = vs,
    by_vars       = exprs(STUDYID, USUBJID),
    new_var       = HISOBPFL,
    # YOUR CODE HERE (condition = ...)
    false_value   = "N",   # subject has VS records but no SYSBP > 160
    missing_value = "N"    # subject has no VS records at all
  )


# Check results ----
adsl %>% count(AGEGR2)
adsl %>% count(HISOBPFL)

# Save output ----
save(adsl, file = file.path("data", "adsl.RDS"), compress = "bzip2")
