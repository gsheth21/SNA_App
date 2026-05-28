# One-Mode Network Analysis App

An interactive Shiny dashboard for exploring and analyzing traditional (one-mode) social networks. This app accompanies the Social Network Analysis textbook and walks students through the core analytical workflow chapter by chapter.

## What This App Does

One-mode networks consist of a single type of node (e.g., people, organizations) connected by edges of a single type (e.g., friendship, collaboration). This app provides a guided, point-and-click environment for loading real-world network datasets, visualizing graph structure, and computing network statistics — without requiring users to write R code.

## Modules (Tabs)

The app is organized into eight chapters that mirror the textbook:

| Tab | Description |
|-----|-------------|
| **Overview** | Dataset summary, graph preview, and key network statistics (density, diameter, reciprocity) |
| **Networks** | Explore node/edge attributes, view adjacency matrices and edge lists, understand directed vs. undirected structure |
| **Connectivity** | Identify connected components, bridges, cut-points, shortest paths, and reachability between nodes |
| **Centrality** | Compute and compare degree, betweenness, closeness, and eigenvector centrality; correlate centrality with node attributes |
| **Communities** | Detect subgroups using clique analysis and Louvain modularity; visualize community membership |
| **Assortativity** | Measure homophily and mixing patterns by node attribute (gender, ethnicity, department, etc.) |
| **Roles** | Structural equivalence analysis — identify nodes that occupy similar positions in the network |
| **Simulation** | Generate synthetic networks (Erdős–Rényi, Barabási–Albert, small-world) and compare their properties |

## Included Datasets

All datasets live in `../shared/data/` as `.rda` files and are loaded via a central registry in `global.R`.

| Key | Label | Nodes | Type | Textbook Chapter |
|-----|-------|-------|------|-----------------|
| `moreno` | Moreno Friendship | 33 | Undirected | Connectivity ⭐ |
| `ifm` | Florentine Families Marriage | 16 | Undirected | Overview, Centrality ⭐ |
| `sampson` | Sampson's Monks | 18 | Undirected | Communities ⭐ |
| `github` | GitHub Collaboration | 174 | Undirected Weighted | Networks |
| `drug_connect` | Hartford Drug Users (largest component) | 193 | Directed | Assortativity ⭐ |
| `drugnet` | Hartford Drug Users (full network) | 293 | Directed | — |
| `htf` / `hta` / `htr` | Hi-Tech Managers (friend/advice/report) | 21 | Directed | Networks ⭐, Roles ⭐ |
| `c`,`d`,`f`,`m`,`mg` | International Trade Networks | 24 | Directed | — |

Not all datasets are available in every chapter — compatibility is controlled by the `chapters` field in the dataset registry in `global.R`.

## File Structure

```
onemode/
├── app.R               # Entry point — sources global.R, ui/ui.R, server/server.R
├── global.R            # Package loading, dataset registry, color palettes, defaults
├── ui/
│   ├── ui.R            # Assembles the full dashboardPage
│   ├── ui_header.R     # Top navigation bar
│   ├── ui_sidebar.R    # Sidebar (dataset picker, layout, appearance controls)
│   ├── overview_ui.R
│   ├── networks_ui.R
│   ├── connectivity_ui.R
│   ├── centrality_ui.R
│   ├── communities_ui.R
│   ├── assortativity_ui.R
│   ├── roles_ui.R
│   └── simulation_ui.R
└── server/
    ├── server.R            # Main server — tab routing, dataset reactive
    ├── overview_server.R
    ├── networks_server.R
    ├── connectivity/       # Connectivity logic split into sub-files
    ├── centrality_server.R
    ├── communities_server.R
    ├── assortativity_server.R
    ├── roles_server.R
    └── simulation_server.R
```

## Running the App

```r
# From the SNA_App/ root directory:
shiny::runApp("onemode")

# Or open onemode/app.R in RStudio and click "Run App"
```

### Required Packages

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",
  "igraph", "network", "sna", "intergraph",
  "visNetwork", "ggplot2", "ggraph", "graphlayouts",
  "plotly", "RColorBrewer", "gridExtra",
  "DT", "dplyr", "scales", "here"
))
```

## How the Code Is Organized

**Data flow:** The sidebar in `ui_sidebar.R` exposes a `selectInput("dataset", ...)` and `selectInput("network_object", ...)`. The main `server.R` watches these inputs and loads the appropriate `.rda` file, exposing a reactive `g()` (igraph object) that every chapter server file consumes.

**Tab routing:** The sidebar navigation triggers `output$tab_content`, which renders the UI for the active chapter. Each chapter has its own `*_ui.R` (layout) and `*_server.R` (logic) file — adding a new chapter only requires creating those two files and registering the tab in `server.R`.

**Dataset registry:** The single source of truth for what datasets exist, what R objects they contain, and which chapters they are compatible with is the `dataset_registry` list in `global.R`. To add a new dataset, add an entry there and drop the `.rda` file in `../shared/data/`.

## Contributing

- Follow the existing file-naming convention: `<chapter>_ui.R` / `<chapter>_server.R`
- New datasets go in `../shared/data/` and must be registered in `global.R`
- The sidebar appearance controls (layout, node size, color) are wired in `ui_sidebar.R` and read by chapter servers via standard `input$*` reactive values
- Run `node scan.js onemode` from the `SNA_App/` root to generate an accessibility report for this app
