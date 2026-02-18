library(shiny)
library(shinydashboard)
library(shinyjs)

library(igraph)
library(network)
library(sna)
library(intergraph)

library(visNetwork)
library(plotly)
library(ggplot2)
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

# Available datasets with metadata
available_datasets <- list(
  ifm = list(
    name = "Florentine Families",
    description = "Marriage relationships between prominent Florentine families in 15th century Renaissance Italy.",
    nodes = 16,
    type = "undirected"
  ),
  moreno = list(
    name = "Moreno 5th Grade",
    description = "Friendship ties among 5th grade students collected by Jacob Moreno in 1934.",
    nodes = 33,
    type = "directed"
  ),
  sampson = list(
    name = "Sampson Monks",
    description = "Friendship relationships among monks in a monastery.",
    nodes = 18,
    type = "directed"
  ),
  drugnet = list(
    name = "Hartford Drug Users",
    description = "Network of drug users in Hartford, Connecticut with demographic attributes.",
    nodes = 293,
    type = "undirected"
  ),
  hi_tech = list(
    name = "Hi-Tech Managers",
    description = "Friendship network among managers in a high-tech company.",
    nodes = 21,
    type = "directed"
  ),
  github = list(
    name = "GitHub Network",
    description = "Collaboration network from GitHub developers.",
    nodes = NA,
    type = "directed"
  )
)

# Print startup message
cat("\n")
cat("====================================================\n")
cat("  ONE-MODE NETWORK ANALYSIS APP\n")
cat("  Social Network Analysis Course (NCSU)\n")
cat("====================================================\n")
cat("\n")
cat("App initialized successfully!\n")
cat("Available datasets:", length(available_datasets), "\n")
cat("\n")
