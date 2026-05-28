# Two-Mode Network Analysis App

An interactive Shiny dashboard for exploring bipartite (two-mode) networks. This app uses a Grime music dataset to walk students through the complete two-mode analysis workflow — from raw data representation to bipartite projections — following the corresponding textbook chapter.

## What This App Does

Two-mode (bipartite) networks connect two distinct types of nodes — in this app, **artists** and **songs** — where edges only cross between the two types (artists are linked to songs they appear on, never directly to other artists). This structure is common in affiliation data: people and organizations, authors and papers, actors and films.

The app demonstrates how to represent, visualize, and analyze such networks, and how to derive one-mode projections from them.

## Modules (Tabs)

| Tab | Description |
|-----|-------------|
| **Edge List** | Raw edge list view (artist → song connections); summary statistics panel |
| **Adjacency Matrix** | Biadjacency matrix visualization showing which artists appear on which songs |
| **Visualization** | Interactive and static bipartite graph plots with color-coded node types (Artist vs. Song) |
| **Degree Centrality** | Degree distribution for both node types; bar charts and data tables for top artists and songs by connectivity |
| **Betweenness Centrality** | Betweenness scores for both modes; identify which artists or songs act as brokers in the network |
| **Projection** | One-mode projections: artist–artist network (shared songs) and song–song network (shared artists); visualize and compare |

## Dataset

**Grime Music Network** — loaded from `../shared/data/grime.rda`

| Object | Description |
|--------|-------------|
| `artist_track_edge` | Edge list data frame: artist name → song title |
| `artist_track_adj` | Biadjacency matrix (artists × songs) |
| `a_t_g` | igraph bipartite graph built from the edge list |
| `a_t_g2` | igraph bipartite graph built from the adjacency matrix (primary graph used throughout) |

All graph objects and summary statistics (`n_artists`, `n_songs`, `n_edges`, `centrality_df`, `projections`) are pre-computed in `global.R` at startup.

The Grime genre — UK hip-hop with dense collaboration networks — is used because its artist/song collaboration structure makes the two-mode concept immediately intuitive.

## File Structure

```
twomode/
├── app.R               # Entry point — sources global.R, ui/ui.R, server/server.R
├── global.R            # Package loading, data loading, graph construction,
│                       #   pre-computed centrality and projections
├── ui/
│   ├── ui.R            # Assembles the full dashboardPage
│   ├── ui_header.R     # Top navigation bar
│   ├── ui_sidebar.R    # Sidebar (network info, layout, node appearance controls)
│   ├── edgelist_ui.R
│   ├── adjmatrix_ui.R
│   ├── viz_ui.R
│   ├── degree_ui.R
│   ├── betweenness_ui.R
│   └── projection_ui.R
└── server/
    ├── server.R            # Main server — tab routing
    ├── edgelist_server.R
    ├── adjmatrix_server.R
    ├── viz_server.R
    ├── centrality_server.R
    └── projection_server.R
```

## Running the App

```r
# From the SNA_App/ root directory:
shiny::runApp("twomode")

# Or open twomode/app.R in RStudio and click "Run App"
```

### Required Packages

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",
  "igraph", "ggplot2", "ggraph", "graphlayouts",
  "visNetwork", "RColorBrewer", "patchwork",
  "DT", "dplyr", "tidyr", "scales", "purrr", "here"
))
```

## How the Code Is Organized

**Data flow:** Unlike the one-mode app, the two-mode app has a **single fixed dataset**. All graph objects are built once in `global.R` and shared across all sessions as read-only globals. No reactive dataset switching is needed — the sidebar only controls visual appearance (layout algorithm, node color, label visibility).

**Projections:** `global.R` pre-computes `bipartite_projection(a_t_g2)`, storing the results as `projections$proj1` (artist–artist) and `projections$proj2` (song–song). The projection tab in `projection_server.R` reads these directly.

**Node type encoding:** `V(a_t_g2)$type` is a logical vector (`FALSE` = Artist, `TRUE` = Song) following igraph's bipartite convention. The human-readable `V(a_t_g2)$mode` attribute (`"Artist"` / `"Song"`) is used for plot legends and data tables.

**Tab routing:** Same pattern as the one-mode app — sidebar navigation triggers `output$tab_content`, which renders the active chapter's UI tag list.

## Contributing

- The dataset is fixed, so extending the app means adding new analysis tabs
- To add a tab: create `<name>_ui.R` and `<name>_server.R`, source them in `ui/ui.R` and `server/server.R`, and add the menu item to `ui_sidebar.R`
- Run `node scan.js twomode` from the `SNA_App/` root to generate an accessibility report for this app
