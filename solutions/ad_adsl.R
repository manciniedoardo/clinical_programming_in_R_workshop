# Name: ADSL - Exercise 1 (MODEL SOLUTION)
# Label: Subject Level Analysis Dataset

library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)
library(stringr)

# Load source datasets ----
dm <- pharmaversesdtm::dm
ex <- pharmaversesdtm::ex
vs <- pharmaversesdtm::vs

dm <- convert_blanks_to_na(dm)
ex <- convert_blanks_to_na(ex)
vs <- convert_blanks_to_na(vs)

# User-defined functions ----
format_agegr1 <- function(x) {
  case_when(
    x < 18             ~ "<18",
    between(x, 18, 64) ~ "18-64",
    x > 64             ~ ">64",
    TRUE               ~ NA_character_
  )
}

# Derivations ----
ex_ext <- ex %>%
  derive_vars_dtm(
    dtc             = EXSTDTC,
    new_vars_prefix = "EXST"
  ) %>%
  derive_vars_dtm(
    dtc             = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

adsl <- dm %>%
  mutate(TRT01P = ARM, TRT01A = ACTARM) %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add  = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
                   !is.na(EXSTDTM),
    new_vars    = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order       = exprs(EXSTDTM, EXSEQ),
    mode        = "first",
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add  = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
                   !is.na(EXENDTM),
    new_vars    = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    order       = exprs(EXENDTM, EXSEQ),
    mode        = "last",
    by_vars     = exprs(STUDYID, USUBJID)
  ) %>%
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>%
  derive_var_trtdurd() %>%
  derive_var_merged_exist_flag(
    dataset_add   = ex,
    by_vars       = exprs(STUDYID, USUBJID),
    new_var       = SAFFL,
    condition     = EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO")),
    false_value   = "N",
    missing_value = "N"
  ) %>%
  mutate(
    AGEGR1 = format_agegr1(AGE),
    DOMAIN = NULL
  )

# Exercise 1a: Derive AGEGR2 ----
adsl <- adsl %>%
  mutate(
    AGEGR2 = case_when(
      AGE < 40             ~ "<40",
      between(AGE, 40, 65) ~ "40-65",
      AGE > 65             ~ ">65",
      TRUE                 ~ NA_character_
    )
  )

# Exercise 1b: Derive HISOBPFL ----
adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add   = vs,
    by_vars       = exprs(STUDYID, USUBJID),
    new_var       = HISOBPFL,
    condition     = VSTESTCD == "SYSBP" & VSSTRESN > 160,
    false_value   = "N",
    missing_value = "N"
  )

# Check results ----
adsl %>% count(AGEGR2)
adsl %>% count(HISOBPFL)

# Save output ----
save(adsl, file = file.path("data", "adsl.RDS"), compress = "bzip2")
