# ==========================================
# 03_rq2_duration_energy.R
# RQ2: Duration vs Energy analysis
# ==========================================

# # ---- Packages ----
# pkgs <- c("tidyverse", "here")
# to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
# if (length(to_install) > 0) install.packages(to_install)

library(tidyverse)
library(here)

dir.create(here("outputs/figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs/tables"),  recursive = TRUE, showWarnings = FALSE)

# ---- Load clustered Spotify dataset (includes audio vars) ----
df_spotify <- readr::read_csv(here("outputs/tables/rq1_clustered_df_spotify.csv"), show_col_types = FALSE)

# Duration in minutes
df_spotify <- df_spotify %>%
  mutate(duration_min = duration_ms / 60000)

# ---- Overall correlation ----
cor_overall <- cor(df_spotify$duration_min, df_spotify$energy, use = "complete.obs")
cat("Overall correlation (duration_min vs energy):", cor_overall, "\n")

write_csv(tibble(correlation = cor_overall),
          here("outputs/tables/rq2_duration_energy_correlation_overall.csv"))

# ---- Scatter plot (overall) ----
p_rq2_all <- ggplot(df_spotify, aes(duration_min, energy)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal() +
  labs(
    title = "Duration vs Energy (Spotify-complete subset)",
    subtitle = paste0("Pearson r = ", round(cor_overall, 3)),
    x = "Song duration (minutes)",
    y = "Energy"
  )

ggsave(here("outputs/figures/rq2_duration_energy_scatter_all.png"),
       p_rq2_all, width = 8, height = 5.5, dpi = 300)

# ---- Period analysis (will show the data sparsity clearly) ----
df_spotify <- df_spotify %>%
  mutate(
    period = case_when(
      year >= 2000 & year <= 2005 ~ "2000–2005",
      year >= 2006 & year <= 2010 ~ "2006–2010",
      year >= 2011 & year <= 2015 ~ "2011–2015",
      year >= 2016 & year <= 2020 ~ "2016–2020",
      year >= 2021 & year <= 2023 ~ "2021–2023",
      TRUE ~ "Other"
    ),
    period = factor(period, levels = c("2000–2005","2006–2010","2011–2015","2016–2020","2021–2023"))
  )

cor_by_period <- df_spotify %>%
  group_by(period) %>%
  summarise(
    n = n(),
    correlation = ifelse(sd(duration_min, na.rm = TRUE) == 0 | sd(energy, na.rm = TRUE) == 0,
                         NA_real_,
                         cor(duration_min, energy, use = "complete.obs")),
    .groups = "drop"
  )

write_csv(cor_by_period,
          here("outputs/tables/rq2_duration_energy_correlation_by_period.csv"))

# Faceted scatter by period
p_rq2_facet <- ggplot(df_spotify, aes(duration_min, energy)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ period) +
  theme_minimal() +
  labs(
    title = "Duration vs Energy by period (Spotify-complete subset)",
    x = "Song duration (minutes)",
    y = "Energy"
  )

ggsave(here("outputs/figures/rq2_duration_energy_scatter_by_period.png"),
       p_rq2_facet, width = 10, height = 6, dpi = 300)

# ---- Yearly trends (means) ----
yearly_trends <- df_spotify %>%
  group_by(year) %>%
  summarise(
    n = n(),
    mean_duration_min = mean(duration_min, na.rm = TRUE),
    mean_energy = mean(energy, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year)

write_csv(yearly_trends,
          here("outputs/tables/rq2_yearly_trends_duration_energy.csv"))

p_trends <- ggplot(yearly_trends, aes(x = year)) +
  geom_line(aes(y = mean_duration_min, group = 1)) +
  geom_point(aes(y = mean_duration_min)) +
  theme_minimal() +
  labs(
    title = "Yearly mean song duration (minutes) in Spotify-complete subset",
    x = "Year", y = "Mean duration (minutes)"
  )

ggsave(here("outputs/figures/rq2_yearly_trends_duration_energy.png"),
       p_trends, width = 8, height = 5, dpi = 300)

cat("\n03_rq2_duration_energy.R complete.\n")
