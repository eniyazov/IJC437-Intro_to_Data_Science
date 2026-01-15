# Audio Characteristic Analysis of Popular Songs (2000-2023):
## Clustering Billboard Songs and Examining the Relationship Between Song Duration and Energy

This repository contains the code, data, and outputs for a data science project completed as part of **IJC437 – Introduction to Data Science**.  
The project analyses songs from the Billboard Hot 100 chart (2000–2023) using Spotify audio features to explore structural patterns in popular music.

---

## Project Overview
The purpose of this project is to apply unsupervised learning and exploratory data analysis techniques to popular music data. Using Spotify audio features linked to Billboard chart performance, the study investigates how songs can be grouped based on their audio characteristics and whether song duration is associated with energy over time.

The project focuses on **descriptive and exploratory analysis**, rather than prediction, and aims to demonstrate practical data science workflows including data cleaning, dimensionality reduction, clustering, and visual interpretation.

---

## Research Questions

**RQ1 – Clustering analysis**  
Can the Billboard Hot 100 songs be clustered based on Spotify audio features, and are the resulting clusters different regarding their performance on the charts?

**RQ2 – Duration and energy trends**  
Is there a relationship between song duration and energy for complete Billboard Hot 100 songs with audio features on Spotify?
---

## Dataset

**Source:**  
Billboard Hot 100 (2000–2023) dataset enriched with Spotify audio features.

- The full dataset contains over 3,000 chart entries.
- Spotify audio features are missing for many records.
- Therefore, analyses are conducted on a **Spotify-complete subset** (n ≈ 486 songs) where all audio features are available.

The full dataset is stored in:
data/raw/billboard_24years_lyrics_spotify.csv


A cleaned, analysis-ready subset is stored in:
data/processed/df_spotify_complete.csv

---

## Project Structure
```
IJC437-Intro_to_Data_Science/
│
├── README.md
├── data/
│ ├── raw/ # Original dataset
│ └── processed/ # Cleaned Spotify-complete subset
│
├── code/
│ ├── 01_data_cleaning.R
│ ├── 02_rq1_pca_kmeans.R
│ ├── 03_rq2_duration_energy.R
│ └── 04_make_all_outputs.R
│
├── outputs/
│ ├── figures/ # PNG figures used in the report
│ └── tables/ # CSV summary tables
```
---

## Methodology Summary

### Data Preparation
- Checked data structure, types, and missing values
- Filtered rows with complete Spotify audio features
- Removed duplicates by song, artist, and year (keeping best ranking)
- Standardised audio features for multivariate analysis

### RQ1 – PCA and K-means Clustering
- Applied Principal Component Analysis (PCA) to reduce dimensionality
- Retained principal components explaining at least 85% of variance
- Selected the number of clusters using elbow and silhouette methods
- Performed K-means clustering (k = 4)
- Interpreted clusters using mean audio feature profiles and visualisations

### RQ2 – Duration and Energy Analysis
- Converted song duration from milliseconds to minutes
- Examined overall correlation between duration and energy
- Analysed duration–energy relationships by time period
- Visualised yearly trends in mean duration and mean energy

---

## Technologies Used
- **R** (RStudio recommended)
- Libraries:  
  `tidyverse`, `ggplot2`, `dplyr`, `skimr`, `naniar`,  
  `factoextra`, `cluster`, `readr`, `scales`

---

## How to Run the Project

### 1. Install Requirements
- Install R from CRAN  
- Install RStudio (recommended)

### 2. Clone the Repository
git clone https://github.com/eniyazov/IJC437-Intro_to_Data_Science.git
cd IJC437-Intro_to_Data_Science

### 3. Then Open RStudio in the project folder and run:
source("code/04_make_all_outputs.R")

This will generate all figures and tables in:
outputs/figures/
outputs/tables/
