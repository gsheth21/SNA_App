library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)

library(igraph)
library(visNetwork)
library(ggplot2)
library(ggraph)
library(RColorBrewer)
library(gridExtra)

library(DT)
library(dplyr)
library(tidyr)
library(scales)
library(purrr)

library(here)

# Set options
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max upload
options(warn = -1)  # Suppress warnings in production

# Helper function: null-coalescing operator
`%||%` <- function(a, b) if (is.null(a)) b else a

# Color palettes - NC State University Theme
network_colors <- list(
  primary = "#CC0000",      # NC State Red
  secondary = "#000000",    # Black
  accent = "#FFFFFF",       # White
  success = "#28a745",      # Green
  warning = "#ffc107",      # Yellow
  danger = "#CC0000",       # NC State Red
  info = "#000000"          # Black
)

ncstate_palette <- c(
  "#CC0000",  # NC State Red
  "#000000",  # Black
  "#FFFFFF",  # White
  "#777777",  # Gray
  "#990000",  # Dark Red
  "#FF3333"   # Light Red
)

# Default network layout algorithms
layout_algorithms <- c(
  "stress" = "Stress (default)",
  "fr" = "Fruchterman-Reingold",
  "kk" = "Kamada-Kawai",
  "circle" = "Circle",
  "nicely" = "Nicely",
  "grid" = "Manual/Grid"
)

# ============================================================
# Load GSS Ego Network Data from local files
# ============================================================

# Load the pre-built ego network data from shared directory
load(here::here("shared", "data", "gss_ego.rda"))

# Objects now available:
# gr.list: igraph objects (alters-only, without ego) - named list by ego_id
# gr.list.ego: igraph objects (with ego included) - named list by ego_id
# ego: ego attributes dataframe
# alterlong: long-format alter attributes
# (edgeslong: NOT loaded - we extract edges from igraph directly)

# ============================================================
# Automatic Data Detection & Preprocessing
# ============================================================

# Get all ego IDs dynamically
all_ego_ids <- as.numeric(names(gr.list))
n_total_egos <- length(all_ego_ids)

# Get vertex attribute names dynamically (from first graph)
first_graph <- gr.list[[1]]
all_vertex_attrs <- igraph::vertex_attr_names(first_graph)
all_vertex_attrs <- all_vertex_attrs[!all_vertex_attrs %in% c("name", "na")]

# Get edge attribute names dynamically
all_edge_attrs <- igraph::edge_attr_names(first_graph)
all_edge_attrs <- all_edge_attrs[!all_edge_attrs %in% c("na")]

# Replace NA weights on ego-alter ties with 3
weight_replace <- function(gr) {
  if ("weight" %in% igraph::edge_attr_names(gr)) {
    igraph::E(gr)$weight <- igraph::E(gr)$weight |> 
      replace_na(3)
  }
  gr
}

gr.list.ego <- gr.list.ego |>
  map(weight_replace)

# Function to add ego attributes to ego vertex (automatically detects attributes)
add_ego_attributes <- function(gr, ego_id, ego_df) {
  ego_row <- ego_df[ego_df$ego_id == as.numeric(ego_id), ]
  ego_index <- length(igraph::V(gr))
  
  if (nrow(ego_row) > 0) {
    # Get all columns from ego_df (excluding ego_id)
    ego_cols <- colnames(ego_df)[colnames(ego_df) != "ego_id"]
    
    for (attr in ego_cols) {
      if (attr %in% colnames(ego_df)) {
        value <- ego_row[[attr]]
        # Only set if not already in graph or if different
        if (!(attr %in% igraph::vertex_attr_names(gr)) || is.na(igraph::vertex_attr(gr, attr, ego_index))) {
          gr <- igraph::set_vertex_attr(gr, name = attr, index = ego_index, value = value)
        }
      }
    }
  }
  
  return(gr)
}

# Apply ego attributes to all networks
gr.list.ego <- imap(gr.list.ego, ~ add_ego_attributes(.x, .y, ego))

# ============================================================
# Create Summary Dataframes for Analysis
# ============================================================

# Ego-level attributes with dummy variables (create on the fly)
ego_summary <- ego |>
  mutate(
    FEMALE = case_when(SEX == 1 ~ 0, SEX == 2 ~ 1, TRUE ~ NA_real_),
    NWHITE = case_when(RACE == 1 ~ 0, TRUE ~ 1)
  )

# Alter-level composition (aggregated to ego level) - dynamically from alterlong
alter_summary <- alterlong |>
  group_by(ego_id) |>
  summarise(
    n_alters = n(),
    prop_fem = mean(SEX == 2, na.rm = TRUE),
    mean_educ = mean(EDUC, na.rm = TRUE),
    .groups = 'drop'
  )

# Edge-level structure (aggregated to ego level) - computed from gr.list
edge_summary <- map_dfr(gr.list, ~ tibble(
  density = igraph::edge_density(.x),
  components = igraph::components(.x)$no,
  deg_centralization = igraph::centr_degree(.x)$centralization
), .id = "ego_id") |>
  mutate(ego_id = as.numeric(ego_id))

# Combined analysis dataframe
analysis_df <- ego_summary |>
  left_join(alter_summary, by = "ego_id") |>
  left_join(edge_summary, by = "ego_id")

# ============================================================
# Helper Functions for Visualization
# ============================================================

# Check if node is ego (always last in gr.list.ego objects)
is_ego_node <- function(gr) {
  n <- length(igraph::V(gr))
  rep(FALSE, n - 1) %>% c(TRUE)
}

# Get alters-only network for given ego
get_alter_network <- function(ego_id) {
  ego_id_str <- as.character(ego_id)
  if (ego_id_str %in% names(gr.list)) {
    return(gr.list[[ego_id_str]])
  }
  return(NULL)
}

# Get alter+ego network for given ego
get_alter_ego_network <- function(ego_id) {
  ego_id_str <- as.character(ego_id)
  if (ego_id_str %in% names(gr.list.ego)) {
    return(gr.list.ego[[ego_id_str]])
  }
  return(NULL)
}

# Get alters data for specific ego
get_ego_alters <- function(ego_id) {
  alterlong |>
    filter(ego_id == !!ego_id)
}

# Get edges for specific ego (extract from igraph)
get_ego_edges <- function(ego_id) {
  ego_id_str <- as.character(ego_id)
  if (ego_id_str %in% names(gr.list)) {
    g <- gr.list[[ego_id_str]]
    edges_df <- igraph::as_edgelist(g, names = TRUE) |>
      as.data.frame()
    colnames(edges_df) <- c("from", "to")
    
    if ("weight" %in% igraph::edge_attr_names(g)) {
      edges_df$weight <- igraph::E(g)$weight
    }
    
    return(edges_df)
  }
  return(NULL)
}

# Get ego attributes
get_ego_profile <- function(ego_id) {
  ego_summary |>
    filter(ego_id == !!ego_id)
}

# Get ego metrics
get_ego_metrics <- function(ego_id) {
  analysis_df |>
    filter(ego_id == !!ego_id)
}
