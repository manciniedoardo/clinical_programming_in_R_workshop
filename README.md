# Clinical Programming in R — Workshop

A 2-hour hands-on workshop tracing the journey from raw clinical trial data
to the evidence used to approve new medicines. Participants build real ADaM
datasets using the `{admiral}` package and visualise results with `{ggplot2}`.

No prior clinical trial experience required! Just bring your R skills.

---

## Prerequisites

- **R** ≥ 4.1 — [download from CRAN](https://cran.r-project.org/)
- **RStudio** ≥ 2022 — [download from Posit](https://posit.co/download/rstudio-desktop/)

---

## Getting Started

### 1. Open the project

Open `clinical_programming_in_R_workshop.Rproj` in RStudio. This sets the
working directory correctly so that all file paths in the exercise scripts
resolve without any changes.

### 2. Restore the package environment

This project uses `{renv}` to ensure everyone runs the same package versions.
Run this **once** in the R console after opening the project:

```r
renv::restore()
```

Agree to any prompts. This installs `{admiral}`, `{pharmaversesdtm}`, `{ggplot2}`,
and all other dependencies. It may take a few minutes on the first run.

Alternatively, you could just install the following packages, making sure to grab the most recent 
versions from CRAN:

```{r, eval=FALSE}
install.packages("pharmaversesdtm") # test data
install.packages("admiral") # tools for ADaM programming
install.packages("ggplot2") # plots
```


### 3. View the slides

The workshop slides have been rendered and published [here](https://manciniedoardo.github.io/clinical_programming_in_R_workshop).

If you want to render the slides locally: open `index.qmd` in RStudio and click the **Render** button (or press
`Ctrl+Shift+K`). The slides will open in your browser. Alternatively, from a terminal in the project root:

```bash
quarto render slides/slides.qmd
```

The rendered file is saved as `docs/index.html` and can be reopened in any
browser at any time.

---

## Repository Structure

```
clinical_programming_in_R_workshop/
│
├── templates/           # Your starting files — open these for the exercises
│   ├── ad_adsl.R        #   Exercise 1: ADSL derivations
│   ├── ad_advs.R        #   Exercise 2: ADVS + MAP derivations
│   └── g_vs_map.R       #   Exercise 3: MAP visualisation
│
├── solutions/           # Model solutions — try the exercises first!
│   ├── ad_adsl.R
│   ├── ad_advs.R
│   └── g_vs_map.R
│
├── data/                # Pre-built datasets (updated when you run exercises)
│   ├── adsl.rda         #   Subject-level dataset
│   └── advs.rda         #   Vital signs dataset
│
└── index.qmd            # Workshop slide deck (render to view)
```

---

## Exercises

Open the template files from the `templates/` folder and follow the
instructions in the comments. **Run them in order** — each exercise
saves its output to `data/` for the next one to use.

| # | File | What you will do |
|---|------|-----------------|
| 1 | `templates/ad_adsl.R` | Add a new age group (`AGEGR2`) and a high systolic BP flag (`HISOBPFL`) to the subject-level dataset |
| 2 | `templates/ad_advs.R` | Derive Mean Arterial Pressure using a built-in admiral function (`MAP`) and a custom formula (`MAPV2`) |
| 3 | `templates/g_vs_map.R` | Plot mean MAP and MAPV2 over time by treatment arm, restricted to the middle age group |

If you get stuck, peek at the matching file in `solutions/` — the solutions
are complete, annotated, and executable top-to-bottom.

---

## Data

The exercises use the **CDISC Pilot Study**, a realistic synthetic dataset
maintained by the pharmaverse and available via the `{pharmaversesdtm}` package.

Pre-built versions of `adsl.RDS` and `advs.RDS` are provided in `data/` so
that you can open any exercise independently. Running the exercises will
overwrite these files with your own derived versions.
