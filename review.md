# Workshop Materials Review

Reviewed: `index.qmd` (slides), `templates/*.R`, `solutions/*.R`, `README.md`, `custom.css`.
No files were modified — this is a read-only review.

---

## 1. High-severity issues (functional bugs)

### 1.1 `templates/ad_adsl.R` saves to the wrong filename
`templates/ad_adsl.R:194`:
```r
save(adsl, file = file.path("data", "adsl.RDS"), compress = "bzip2")
```
This uses `save()` (an R-data/environment format, conventionally `.rda`/`.RData`) but names the file `adsl.RDS` (uppercase, the extension conventionally used for `saveRDS()`/`readRDS()` single-object files). Every other file in the project — `solutions/solution_ad_adsl.R:100`, `templates/ad_advs.R:178`, `solutions/solution_ad_advs.R:98`, and both `g_vs_map.R` files — correctly reads/writes lowercase `adsl.rda` / `advs.rda` with `save()`/`load()`.

**Impact:** if a participant fills in Exercise 1 correctly and runs the template top-to-bottom, it will write `data/adsl.RDS`, *not* `data/adsl.rda`. `templates/ad_advs.R:36` then does `load(file.path("data", "adsl.rda"))`, which will silently load the stale, pre-built `data/adsl.rda` that ships in the repo instead of the participant's own output — Exercise 2 would quietly run against the wrong data (or fail outright for anyone who deletes/renames the pre-built file). This is currently masked only because a pre-built `data/adsl.rda` is checked into git.

**Fix:** change `"adsl.RDS"` → `"adsl.rda"` on `templates/ad_adsl.R:194`.

### 1.2 Exercise 3's stated age filter contradicts the code everywhere
The task prose says one thing; every actual filter/plot uses another:

| Location | Says |
|---|---|
| `index.qmd:819` (task text) | "restricted to patients aged **>65**" |
| `README.md:98` | "restricted to the oldest age group" |
| `templates/g_vs_map.R:5` (header comment) | `restricted to patients in the ">65" age group` |
| `index.qmd:825`, `templates/g_vs_map.R:20,25` (actual filter) | `AGEGR2 %in% c("55-65")` |
| `solutions/solution_g_vs_map.R:12,17,27,42` | `AGEGR2 == "55-65"`, subtitle "Age group: 55-65 years" |
| `solutions/solution_g_vs_map_faceted.R:12,17,30,46` | same, "55-65" |

Every code path — template, both solutions, and the slide's own code excerpt — actually filters to the **middle** age group (`"55-65"`), while the task description and README both tell participants (and the audience) they're looking at the **oldest** group (`">65"`). This is the single most confusing inconsistency in the deck, since it appears directly above the contradicting code block on the same slide (`index.qmd:819` vs `:825`).

**Fix:** decide which age group Exercise 3 is meant to illustrate and make all six locations agree (probably easiest to update the prose/comments to "55-65" since the code, both solutions, and all four saved plot images already reflect that group).

---

## 2. Typos

| Location | Issue |
|---|---|
| `index.qmd:627` | "High Systolic Blood **Pressus** Flag" → "Pressure" |
| `index.qmd:671` | `` the `ADS`L dataset `` — stray closing backtick splits "ADSL"; should be `` the `ADSL` dataset `` |
| `index.qmd:680` | "each patient has multiple rows **the the** dataset" → "rows in the dataset" |
| `index.qmd:692` | `` `"Systolic blood **pressue** (mmHg)` `` → "pressure"; also missing the closing `"` before the backtick (every other example in that table cell is fully quote+backtick closed, e.g. `` `"BASELINE"` ``) |
| `index.qmd:819` | "split by treatment arm **,(**\`TRT01A"\`**)**" — stray comma, and a stray `"` trapped inside the backticks (`` `TRT01A"` ``). Should read "split by treatment arm (`TRT01A`)" |
| `index.qmd:96` | "...is long and complex! **it** can loosely be categorised..." — lowercase "it" starting a new sentence after "!" |
| `index.qmd:295` vs `:343` | ADAE is expanded twice with different wording: "Adverse **Event** Analysis Dataset" (295) vs "Adverse **Events** Analysis Dataset" (343) — pick one |

---

## 3. Formatting inconsistencies

### 3.1 Broken "blue italic aside" markup, used 14 times
Every "narrator aside" line in the deck uses this pattern, e.g. `index.qmd:104`:
```
[*Let's go through these stages one by one...*]({style="color:blue;"})
```
This is **not valid Pandoc bracketed-span syntax**. `[text]({attrs})` is parsed as a regular Markdown link `[text](url)` where the "URL" is the literal string `{style="color:blue;"}` — it does not apply a color style at all, it (at best) creates a dead/garbage link. The correct bracketed-span syntax has no parentheses:
```
[*Let's go through these stages one by one...*]{style="color:blue;"}
```
This same broken pattern appears at lines 104, 129, 163, 279, 312, 427, 455, 557, 578, 676, 702, 741, 801, and 862 — i.e. essentially every transition line in the whole deck. Worth a single find-and-replace once confirmed (removing the parentheses around `{style=...}`), after checking how it currently actually renders (it's possible the extra `()` is silently swallowed by revealjs/pandoc rather than becoming a visible link — but it should be fixed either way since it's not doing what was intended).

### 3.2 Bold text that won't render as bold
`index.qmd:343`:
```
**ADAE (Adverse Events Analysis Dataset) ** — one row per patient...
```
There's a trailing space before the closing `**`. Per CommonMark's flanking-delimiter rules, a closing `**` preceded by whitespace is not "right-flanking" and won't close the emphasis — this will likely render as literal double-asterisks rather than bold, unlike the other ADaM section headers (`ADSL`/`ADVS`) which don't have the extra space before their closing `**`.

### 3.3 Copy-pasted callout with wrong title/content
`index.qmd:813-815`:
```
:::{.callout-note title="ADSL"}
- This exercise will use the `ADVS` dataset you created in Exercise 1. ...
```
This callout is in the **Exercise 3** section but is a copy of the Exercise 2 callout (`index.qmd:670-671`) with the dataset name swapped but not the title or the "Exercise 1" reference. It should read `title="ADVS"` and "...you created in **Exercise 2**" (ADVS was built in Exercise 2, not Exercise 1).

### 3.4 Backtick usage for dataset/variable names — mostly consistent, a few gaps
The deck is otherwise very disciplined about backticking dataset names (`` `DM` ``, `` `ADSL` ``, `` `ADVS` ``...), variable names (`` `AGEGR2` ``, `` `HISOBPFL` ``...) and package names in curly braces (`` `{admiral}` ``, `` `{ggplot2}` ``...). The exceptions are the ones already listed above (§2 `` `ADS`L ``, and the unterminated `` `"Systolic blood pressue (mmHg)` `` cell). Also minor: `` `PARAM  ` `` (index.qmd:692) and `` `"AFTER STANDING FOR 3 MINUTES" ` `` (index.qmd:694) both have stray trailing spaces baked inside the backticks (presumably for source alignment) — harmless but slightly sloppy since the space is inside the code span and will render as part of it.

### 3.5 Exercise 3's own divider slide breaks the pattern used by Exercises 1 & 2
Exercises 1 and 2 each use a two-slide pattern: a `{.center background-color="#E8F4FD"}` divider slide containing *only* the title, then a `---` rule, then the content slide. Exercise 3's divider slide (`index.qmd:806-810`) instead packs in an extra line ("Open **`templates/g_vs_map.R`**") and has no `---` separating it from the next `##` slide:
```
## Exercise 3: A Simple Visualisation {.center background-color="#E8F4FD"}

Open **`templates/g_vs_map.R`**

## Exercise 3: A Simple Visualisation
```
Not wrong (Quarto revealjs starts a new slide at every `##` regardless), but it's the only divider slide in the deck carrying content, which is a bit inconsistent visually/structurally.

### 3.6 "2a with no 2b" / mismatched exercise numbering in `ad_advs.R`
`templates/ad_advs.R:6-8` (header comment):
```
# Exercises:
#   2a) Derive Mean Arterial Pressure (MAP) using admiral's built-in function
#   2b) Derive an alternative MAP (MAPV2) using a custom formula
```
But `derive_param_map()` (the "MAP" part) is fully provided in the template — it isn't an exercise, there's no blank/TODO for it. The one actual fill-in-the-blank in the file is the MAPV2 derivation, and it's labelled `# Exercise 2a:` in the body (`templates/ad_advs.R:110`), matching `index.qmd`'s "Exercise 2a — Derive `MAPV2`" heading. So the header comment's "2a/2b" list doesn't match the body, which only has a "2a". Recommend simplifying the header comment to list just the one exercise, e.g. "2a) Derive an alternative MAP (MAPV2) using a custom formula".

### 3.7 README extension typos
`README.md:80-81,110`: refers to `adsl.RDS` / `advs.RDS`, but the files actually shipped in `data/` (and produced by `save()`/`load()`) are `adsl.rda` / `advs.rda`. Same root cause as §1.1 — worth fixing together.

### 3.8 Minor capitalization nit in the agenda table
`index.qmd:76`: "Exercise Setup, **T**est **d**ata and the packages..." — inconsistent capitalization of "Test data" versus the Title Case used for the other agenda rows ("Background:", "Exercise Setup", "Wrap-up and next steps").

---

## 4. Content/clarity suggestions (not errors, but worth a look)

- **`index.qmd:754`** — the Exercise 2a task question asks "Which patient has the highest **MAP** and at what visit?" but the exercise is about deriving **MAPV2**; the answer given (`index.qmd:796`) is phrased as "Highest MAP is 158.0 mmHg..." Consider explicitly saying "MAPV2" in both the question and the answer so participants don't wonder whether you mean the original `derive_param_map()` output or the new custom parameter.
- Exercise 2 has only a "2a" sub-part (no "2b"), while Exercise 1 has "1a" and "1b". Since Exercise 2 is a single derivation, consider dropping the "a" suffix entirely (just "Exercise 2 — Derive `MAPV2`") to avoid implying a missing second part.
- The workshop is titled "Workshop for Ukraine" in the subtitle (`index.qmd:3`) — worth double-checking this is still the intended framing/context before it goes out again, since nothing else in the deck currently references that context (no mention of why, or where proceeds/attendance are going, etc.) — might be worth a one-line callout on the title slide if this is a charity/fundraising angle, otherwise it may read as a stray subtitle to newcomers.
- `templates/*.R` are excellent — the inline comments explaining *why* each `admiral` call is needed (not just what it does) are genuinely some of the best "teaching-code" comments I've seen; worth preserving that density when the age-group/filename fixes above are made.

---

## 5. Quarto/revealjs feature suggestions

A few `revealjs` features that could enhance the deck, given its current structure (heavy use of `::: fragment`, two-column layouts, callouts, code blocks):

1. **Speaker notes** (`::: {.notes}`) — you could stash the answers/talking points (e.g. the "why" behind each derivation, or timing cues) as speaker notes rather than as visible slide text, then use the `S` key or `?speaker-view` during delivery. Keeps the audience-facing slide cleaner while still giving you a script.
2. **`auto-animate: true`** on consecutive slides — e.g. the `ad_adsl.R`/`ad_advs.R`/`g_vs_map.R` code blocks that get incrementally built up (task → hint → solution) could morph between slides instead of just appearing as a new block, which reads nicely for "watch this line get added" moments (like the `AGEGR2` and `MAPV2` additions).
3. **`code-line-numbers` with `{code-line-numbers="7-9"}`** on individual chunks — the deck currently sets `code-line-numbers: false` globally (`index.qmd:10`); consider re-enabling it selectively per-chunk on the longer `admiral` pipelines (e.g. the `derive_vars_merged` example around `index.qmd:527`) so you can highlight just the new/relevant lines during the walkthrough instead of the whole block.
4. **`menu` / `chalkboard` plugins** — RevealJS's chalkboard plugin (`revealjs-plugins: [chalkboard]`) lets you annotate live over the `admiral` pipeline diagrams or the SDTM→ADaM flow image during Q&A, which could be handy for an interactive workshop format.
5. **`preview-links: true`** — since the deck links out to the GitHub repo and pharmaverse.org multiple times, this option opens external links in an in-deck iframe overlay instead of navigating away from the slideshow (useful if presenting full-screen).
6. **Progressive `fragment` index control** (`fragment-index`) — currently fragments reveal in document order; for the "Key features of SDTM" / "Key features of ADaM" callout+bullet combos, explicit `fragment-index` values would let you reveal the callout box before/after specific bullets rather than being locked to source order — probably not needed now but useful if you restructure those slides later.
7. **`smaller-table` class is already custom (`.small-table` in `custom.css`)** — nice touch; consider also using Quarto's built-in `tbl-colwidths` on the plain Markdown tables (e.g. the ADSL/ADVS variable tables) instead of relying on manual column padding with spaces (as seen in `index.qmd:687-698`), which would remove the need for things like the stray trailing-space-in-backticks issue noted in §3.4.
