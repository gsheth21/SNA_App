library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)

library(igraph)
library(visNetwork)
library(ggplot2)
library(ggraph)
library(graphlayouts)
library(RColorBrewer)
library(patchwork)

library(DT)
library(dplyr)
library(tidyr)
library(scales)
library(purrr)

library(here)

# Options
options(shiny.maxRequestSize = 30*1024^2)
options(warn = -1)

# Null-coalescing operator
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================
# Load grime dataset
# ============================================================
load(here::here("shared", "data", "grime.rda"))
# Provides: artist_track_edge, artist_track_adj

# ============================================================
# Build network objects
# ============================================================

# 13.1 — from edgelist
a_t_g <- graph_from_data_frame(artist_track_edge, directed = FALSE)
V(a_t_g)$type <- bipartite_mapping(a_t_g)$type

# 13.2 — from affiliation matrix (primary graph used throughout)
a_t_g2 <- graph_from_biadjacency_matrix(artist_track_adj)

# Add human-readable mode label used in styled plots
V(a_t_g2)$mode <- ifelse(V(a_t_g2)$type, "Song", "Artist")

# ============================================================
# Pre-compute centrality data frame (13.4 / 13.5)
# ============================================================
centrality_df <- data.frame(
  degree  = igraph::degree(a_t_g2),
  between = igraph::betweenness(a_t_g2),
  name    = V(a_t_g2)$name,
  type    = ifelse(V(a_t_g2)$type == TRUE, "Song", "Artist"),
  stringsAsFactors = FALSE
)

# ============================================================
# Pre-compute projections (13.6)
# ============================================================
projections <- bipartite_projection(a_t_g2)
# projections$proj1 = artist-artist network
# projections$proj2 = song-song network

# ============================================================
# Summary stats (used in sidebar and edgelist/adjmatrix summaries)
# ============================================================
n_artists <- sum(V(a_t_g2)$type == FALSE)
n_songs   <- sum(V(a_t_g2)$type == TRUE)
n_edges   <- igraph::ecount(a_t_g2)

artist_deg_mean <- round(mean(centrality_df$degree[centrality_df$type == "Artist"]), 2)
song_deg_mean   <- round(mean(centrality_df$degree[centrality_df$type == "Song"]),   2)

# a_t_g summary stats (edgelist-built graph)
n_nodes_atg <- igraph::vcount(a_t_g)
n_edges_atg <- igraph::ecount(a_t_g)
