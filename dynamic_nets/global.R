library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)

library(ndtv)
library(tsna)
library(networkDynamic)
library(network)
library(sna)

library(ggplot2)
library(dplyr)
library(htmlwidgets)
library(htmltools)

library(here)

options(shiny.maxRequestSize = 30 * 1024^2)

`%||%` <- function(a, b) if (is.null(a)) b else a

# ── Load Data ──────────────────────────────────────────────────────────────────
# frat_n: list of 15 directed network objects (weekly top-3 friendship nominations)
load(here::here("shared", "data", "frat_graphs.rda"))

N_TIME_POINTS <- length(frat_n)   # 15
MAX_TIME      <- N_TIME_POINTS - 1 # 14 (0-based upper bound for networkDynamic)

# Build networkDynamic object — one entry per time point
frat_tnet <- networkDynamic(network.list = frat_n)

# Precompute animation layout once at startup (expensive but shared across sessions)
message("Computing animation layout (this may take a moment)...")
compute.animation(frat_tnet)
message("Animation layout ready.")

# Precompute structural statistics across all time points
net_stats <- data.frame(
  time_point   = seq_len(N_TIME_POINTS),
  density      = sapply(frat_n, gden),
  transitivity = sapply(frat_n, gtrans),
  reciprocity  = sapply(frat_n, grecip),
  v_count      = sapply(frat_n, network.size),
  e_count      = sapply(frat_n, network.edgecount)
)

# ── Theme ──────────────────────────────────────────────────────────────────────
ncstate_red  <- "#CC0000"
ncstate_dark <- "#000000"

cat("\n====================================================\n")
cat("  DYNAMIC NETWORK ANALYSIS APP\n")
cat("  Newcomb Fraternity Study | NCSU SNA Course\n")
cat("====================================================\n\n")
cat("Loaded:", N_TIME_POINTS, "time points\n\n")
