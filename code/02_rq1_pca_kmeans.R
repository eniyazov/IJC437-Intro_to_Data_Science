# ==========================================
# 02_rq1_pca_kmeans.R
# PCA + K-means clustering + cluster interpretation outputs
# ==========================================

# # ---- Packages ----
# pkgs <- c("tidyverse", "here", "factoextra", "cluster", "scales")
# to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
# if (length(to_install) > 0) install.packages(to_install)

library(tidyverse)
library(here)
library(factoextra)
library(cluster)
library(scales)

# ---- Paths ----
dir.create(here("outputs/figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs/tables"),  recursive = TRUE, showWarnings = FALSE)

# ---- Load processed Spotify-complete dataset ----
df_spotify <- readr::read_csv(here("data/processed/df_spotify_complete.csv"), show_col_types = FALSE)

audio_vars <- c(
  "danceability","energy","key","loudness","mode","speechiness",
  "acousticness","instrumentalness","liveness","valence","tempo",
  "duration_ms","time_signature"
)

# ---- Scaling + PCA ----
X <- df_spotify %>% select(all_of(audio_vars)) %>% as.data.frame()
X_scaled <- scale(X)

pca <- prcomp(X_scaled, center = TRUE, scale. = FALSE)

# Variance table
pca_var <- (pca$sdev^2) / sum(pca$sdev^2)
pca_var_tbl <- tibble(
  pc = paste0("PC", seq_along(pca_var)),
  variance = pca_var,
  cumulative_variance = cumsum(pca_var)
)

write_csv(pca_var_tbl, here("outputs/tables/rq1_pca_variance_table.csv"))

# Scree plot
p_scree <- ggplot(pca_var_tbl, aes(x = pc, y = variance)) +
  geom_col() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "PCA Scree Plot (Spotify-complete subset)", x = "Principal Components", y = "Proportion of variance")

ggsave(here("outputs/figures/rq1_pca_scree.png"), p_scree, width = 8, height = 5, dpi = 300)

# Choose number of PCs for >= 85% variance
k_pcs <- pca_var_tbl %>%
  filter(cumulative_variance >= 0.85) %>%
  slice(1) %>%
  mutate(k = as.integer(str_remove(pc, "PC"))) %>%
  pull(k)

cat("Number of PCs retained for >=85% variance:", k_pcs, "\n")

pc_scores <- as.data.frame(pca$x[, 1:k_pcs, drop = FALSE])

# ---- Choose k: elbow + silhouette ----
p_elbow <- factoextra::fviz_nbclust(pc_scores, kmeans, method = "wss") +
  theme_minimal() +
  labs(title = "Elbow method for choosing k (Spotify-complete subset)")
ggsave(here("outputs/figures/rq1_kmeans_elbow.png"), p_elbow, width = 8, height = 5, dpi = 300)

p_sil <- factoextra::fviz_nbclust(pc_scores, kmeans, method = "silhouette") +
  theme_minimal() +
  labs(title = "Silhouette method for choosing k (Spotify-complete subset)")
ggsave(here("outputs/figures/rq1_kmeans_silhouette.png"), p_sil, width = 8, height = 5, dpi = 300)

# ---- Fit final K-means ----
set.seed(123)
k_final <- 4

km <- kmeans(pc_scores, centers = k_final, nstart = 50)
df_spotify <- df_spotify %>% mutate(cluster = factor(km$cluster))

write_csv(df_spotify, here("outputs/tables/rq1_clustered_df_spotify.csv"))

# ---- Cluster plot PC1 vs PC2 ----
pc12 <- as.data.frame(pca$x[, 1:2]) %>%
  mutate(cluster = df_spotify$cluster)

p_clusters <- ggplot(pc12, aes(PC1, PC2, color = cluster)) +
  geom_point(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Song clusters in PCA space (Spotify-complete subset)", x = "PC1", y = "PC2")

ggsave(here("outputs/figures/rq1_clusters_pc1_pc2.png"), p_clusters, width = 8, height = 5.5, dpi = 300)

# ---- Cluster sizes ----
p_cluster_sizes <- df_spotify %>%
  count(cluster) %>%
  ggplot(aes(cluster, n)) +
  geom_col() +
  theme_minimal() +
  labs(title = "Cluster sizes (Spotify-complete subset)", x = "Cluster", y = "Number of songs")

ggsave(here("outputs/figures/rq1_cluster_sizes.png"), p_cluster_sizes, width = 7, height = 5, dpi = 300)

# ---- Cluster profiles (mean audio features) ----
cluster_profile <- df_spotify %>%
  group_by(cluster) %>%
  summarise(across(all_of(audio_vars), \(x) mean(x, na.rm = TRUE)),
            n = n(), .groups = "drop") %>%
  arrange(cluster)

write_csv(cluster_profile, here("outputs/tables/rq1_cluster_profiles_means.csv"))

# ---- Cluster profile heatmap (scaled means) ----
profiles_long <- cluster_profile %>%
  select(cluster, all_of(audio_vars)) %>%
  pivot_longer(-cluster, names_to = "feature", values_to = "mean_value") %>%
  group_by(feature) %>%
  mutate(mean_scaled = as.numeric(scale(mean_value))) %>%
  ungroup()

p_heat <- ggplot(profiles_long, aes(feature, cluster, fill = mean_scaled)) +
  geom_tile() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Cluster profile heatmap (scaled feature means)",
    x = "Audio feature", y = "Cluster"
  )

ggsave(here("outputs/figures/rq1_cluster_profile_heatmap.png"), p_heat, width = 11, height = 5, dpi = 300)

# ---- Ranking by cluster ----
cluster_ranking <- df_spotify %>%
  group_by(cluster) %>%
  summarise(
    n = n(),
    mean_ranking = mean(ranking, na.rm = TRUE),
    median_ranking = median(ranking, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(cluster)

write_csv(cluster_ranking, here("outputs/tables/rq1_cluster_ranking_summary.csv"))

p_rank_box <- ggplot(df_spotify, aes(cluster, ranking)) +
  geom_boxplot() +
  theme_minimal() +
  labs(
    title = "Ranking distribution by cluster (Spotify-complete subset)",
    x = "Cluster",
    y = "Billboard ranking (lower is better)"
  )

ggsave(here("outputs/figures/rq1_ranking_by_cluster_boxplot.png"), p_rank_box, width = 7, height = 5, dpi = 300)

# ---- Save summary info ----
summary_rq1 <- tibble(
  n_rows_spotify_complete = nrow(df_spotify),
  k_pcs_85pct = k_pcs,
  kmeans_k_final = k_final
)
write_csv(summary_rq1, here("outputs/tables/rq1_summary.csv"))

cat("\n02_rq1_pca_kmeans.R complete.\n")
