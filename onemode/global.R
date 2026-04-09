library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)

library(igraph)
library(network)
library(sna)
library(intergraph)

library(visNetwork)
library(plotly)
library(ggplot2)
library(ggraph)
library(graphlayouts)
library(RColorBrewer)
library(gridExtra)

library(DT)
library(dplyr)
library(scales)

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
  success = "#28a745",      # Green (keep for success states)
  warning = "#ffc107",      # Yellow (keep for warnings)
  danger = "#CC0000",       # NC State Red
  info = "#000000"          # Black
)

# NC State Color Scheme for visualizations
ncstate_palette <- c(
  "#CC0000",  # NC State Red
  "#000000",  # Black
  "#FFFFFF",  # White
  "#777777",  # Gray (for contrast)
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

# Dataset registry — single source of truth for all dataset metadata
# Each entry: label (shown in UI), file (.rda filename), objects (named list of R objects inside),
# chapters (which tabs this dataset is compatible with)
dataset_registry <- list(

  moreno = list(
    label    = "Moreno Friendship",
    file     = "moreno",
    objects  = list(moreno = "Moreno Network — 33 nodes, undirected"),
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "communities", "assortativity", "roles")
  ),

  ifm = list(
    label    = "Florentine Families Marriage",
    file     = "ifm",
    objects  = list(ifm = "Marriage Network — 16 nodes, undirected"),
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "communities", "assortativity", "roles")
  ),

  sampson = list(
    label    = "Sampson's Monks",
    file     = "sampson",
    objects  = list(sampson = "Monks Network — 18 nodes, undirected"),
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "communities", "assortativity", "roles")
  ),

  github = list(
    label    = "GitHub Collaboration",
    file     = "github",
    objects  = list(github = "GitHub Network — 174 nodes, undirected weighted"),
    # roles excluded: UW networks don't fit structural equivalence analysis
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "communities", "assortativity")
  ),

  drugnet = list(
    label    = "Hartford Drug Users",
    file     = "drugnet",
    objects  = list(
      drug_connect = "Largest Component — 193 nodes, directed",
      drugnet      = "Full Network — 293 nodes, directed"
    ),
    # communities excluded: cliques/louvain hard-fail on directed graphs
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "assortativity", "roles")
  ),

  hi_tech = list(
    label    = "Hi-Tech Managers",
    file     = "hi_tech",
    objects  = list(
      htf = "Friendship Network — 21 nodes, directed",
      hta = "Advice Network — 21 nodes, directed",
      htr = "Reporting Network — 21 nodes, directed (sparse)"
    ),
    # communities excluded: directed graph
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "assortativity", "roles")
  ),

  tradenets = list(
    label    = "International Trade Networks",
    file     = "tradenets",
    objects  = list(
      c  = "Cement — 24 nodes, directed",
      d  = "Diplomatic Exchange — 24 nodes, directed",
      f  = "Food/Agriculture — 24 nodes, directed",
      m  = "Minerals — 24 nodes, directed",
      mg = "Metal Goods — 24 nodes, directed weighted"
    ),
    # communities excluded: directed graph
    chapters = c("overview", "networks", "connectivity", "centrality",
                 "assortativity", "roles")
  )
)

# Canonical default dataset + object for each chapter
# Based on the book's own dataset for each chapter (starred in the mapping doc)
chapter_defaults <- list(
  overview      = list(dataset = "ifm",      object = "ifm"),
  networks      = list(dataset = "hi_tech",  object = "htf"),
  connectivity  = list(dataset = "moreno",   object = "moreno"),
  centrality    = list(dataset = "ifm",      object = "ifm"),
  communities   = list(dataset = "sampson",  object = "sampson"),
  assortativity = list(dataset = "drugnet",  object = "drug_connect"),
  roles         = list(dataset = "hi_tech",  object = "htf"),
  simulation    = NULL
)

# Print startup message
cat("\n")
cat("====================================================\n")
cat("  ONE-MODE NETWORK ANALYSIS APP\n")
cat("  Social Network Analysis Course (NCSU)\n")
cat("====================================================\n")
cat("\n")
cat("App initialized successfully!\n")
cat("Available datasets:", length(dataset_registry), "\n")
cat("\n")
