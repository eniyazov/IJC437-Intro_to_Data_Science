# ==========================================
# 01_data_cleaning.R
# Data loading, audit, missingness, subset creation
# ==========================================

# # ---- Packages ----
# pkgs <- c("tidyverse", "skimr", "naniar", "here")
# to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
# if (length(to_install) > 0) install.packages(to_install)

library(tidyverse)
library(skimr)
library(naniar)
library(here)

# ---- Paths ----
dir.create(here("data/processed"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs/figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs/tables"),  recursive = TRUE, showWarnings = FALSE)

raw_path <- here("data/raw/billboard_24years_lyrics_spotify.csv")

# ---- Load ----
raw <- readr::read_csv(raw_path, show_col_types = FALSE)

# ---- Quick audit ----
cat("Raw rows:", nrow(raw), "\n")
cat("Raw cols:", ncol(raw), "\n")
cat("Year range:", min(raw$year, na.rm = TRUE), "-", max(raw$year, na.rm = TRUE), "\n")

# Save audit tables (helpful for appendices)
raw %>% slice(1:20) %>%
  write_csv(here("outputs/tables/data_example_first20_raw.csv"))

# Missingness by variable (full dataset)
naniar::miss_var_summary(raw) %>%
  write_csv(here("outputs/tables/missingness_by_variable_raw.csv"))

# Save a light "df_all_basic" table for repo use (optional but useful)
df_all <- raw %>%
  filter(!is.na(year), year >= 2000, year <= 2023) %>%
  filter(!is.na(ranking), ranking >= 1) %>%
  mutate(
    year = as.integer(year),
    ranking = as.integer(ranking)
  )

write_csv(df_all, here("outputs/tables/df_all_basic.csv"))

# ---- Define Spotify audio variables ----
audio_vars <- c(
  "danceability","energy","key","loudness","mode","speechiness",
  "acousticness","instrumentalness","liveness","valence","tempo",
  "duration_ms","time_signature"
)

# ---- Create Spotify-complete subset ----
# Keep only rows with complete audio variables (no NA in any of these)
df_spotify <- df_all %>%
  filter(if_all(all_of(audio_vars), ~ !is.na(.)))

cat("Spotify-complete rows:", nrow(df_spotify), "\n")

# Deduplicate: keep best ranking per (song, artist, year)
df_spotify <- df_spotify %>%
  arrange(song, band_singer, year, ranking) %>%
  group_by(song, band_singer, year) %>%
  slice(1) %>%
  ungroup()

cat("Spotify-complete rows after dedup:", nrow(df_spotify), "\n")

# Save Spotify subset for reproducible analysis
write_csv(df_spotify, here("data/processed/df_spotify_complete.csv"))

# Missingness check on Spotify subset (should be 0 for audio vars)
naniar::miss_var_summary(df_spotify %>% select(all_of(audio_vars))) %>%
  write_csv(here("outputs/tables/missingness_df_spotify.csv"))

# ---- Visual: missingness map for RQ2-selected columns ----
p_miss_selected <- df_all %>%
  select(song, year, energy, duration_ms) %>%
  naniar::vis_miss() +
  theme_minimal() +
  labs(title = "Missingness map: selected variables (full dataset)")

ggsave(
  filename = here("outputs/figures/missingness_full_selected_vars.png"),
  plot = p_miss_selected,
  width = 8, height = 4.5, dpi = 300
)

# ---- Visual: songs per year (full dataset) ----
p_songs_year <- df_all %>%
  count(year) %>%
  ggplot(aes(x = year, y = n)) +
  geom_col() +
  theme_minimal() +
  labs(title = "Number of songs per year (full dataset)", x = "Year", y = "Count")

ggsave(
  filename = here("outputs/figures/eda_songs_per_year_full.png"),
  plot = p_songs_year,
  width = 8, height = 4.5, dpi = 300
)

cat("\n01_data_cleaning.R complete.\n")
