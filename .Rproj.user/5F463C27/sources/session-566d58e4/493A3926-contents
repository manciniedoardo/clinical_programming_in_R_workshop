---
title: ".CLAUDE"
output: html_document
---

I am going to run a workshop with the following description: 

"Have you ever wondered how raw patient data from a clinical trial transforms into the actual evidence used to 
approve new medicines? This two-hour, hands-on workshop aims to answer this question by giving you a glimpse into the 
clinical trial data pipeline. We’ll start with a crash ncourse on industry data standards, tracing the journey from 
raw data to SDTM (Study Data Tabulation Model), into analysis-ready ADaM datasets, and finally into Tables, Listings, 
and Graphs (TLGs). From there, you will step into the shoes of a clinical statistical programmer: firstly, you will 
be guided through creating your own simple ADaM dataset(s) using the {admiral} package and test data. Then, you will 
bring your analyses to life using {ggplot2} and a tabulation package of your choice to build the kinds of polished 
visualizations and summary tables that drive real-world medical breakthroughs. No prior clinical trial experience is 
required, just bring your foundation R skills and your curiosity!"

My idea for this workshop is to structure it as follows:

- Brief introduction into the end to end data flow for a clinical trial (raw data to sdtm to adam to TLGs for analysis,
explaining why we have each stage. That is:
  - Raw data: collected from various sources, labs, etc.
  - SDTM: Process of combining data pertaining to the same domain (e.g. combining urine and blood tests into one
    LB dataset)
  - ADaM: Preparing the SDTM data for analysis and combining it (e.g. the dataset of adverse events can be cross-
    referenced with the lab and vital signs dataset to understand how patient was at the time of an AE). Or a
    derived parameter can be computed, e.g. the mean arterial pressure.
  - TLG: Extracting meaningful information from the ADam datasets, (e.g. a table of demographics for the study or
    a graph of mean arterial pressure over time)

- Brief introduction to the ADSL and ADVS ADaMs

- Exercise 1: Working with ADSL
  - 1a) Deriving a new age group category
  - 1b) Deriving a new population flag, e.g. patients with blood pressure exceeding a certain value

- Exercise 2: Working with ADVS
  - 2a) Derive mean arterial pressure
  - 2b) Derive a variant of mean arterial pressure with a different formula
  
- Exercise 3: Make table and graph
  - Make two graphs of mean arterial pressure over time using the two parameters. Perhaps generate for patients
    only in one of the  age group categories we made in ADSL.
