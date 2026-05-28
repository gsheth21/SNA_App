# Dynamic Network Analysis App

An interactive Shiny dashboard for exploring how network structure changes over time. This app uses the Newcomb Fraternity Study (1956) to demonstrate the core concepts and visualizations of longitudinal network analysis — following the corresponding textbook chapter.

## What This App Does

Dynamic networks add a **time dimension** to network data: instead of a single snapshot, there is a sequence of networks measured at different points in time. This app lets students observe how friendships form and dissolve over a semester, measure how structural properties evolve, and animate the network's history.

## Modules (Tabs)

| Tab | Description |
|-----|-------------|
| **Stats** | Value boxes showing current network statistics (density, transitivity, reciprocity, edge count) for the selected time point; line chart of any metric across all 15 time points |
| **Snapshots** | Single-time-point network plot with a time slider; toggle to "compare mode" to display two time points side by side for direct comparison |
| **Multi-Time** | Three sub-views for comparing structure across time: **Filmstrip** (all 15 time points as a grid of small-multiple plots), **Time Prism** (2–4 selected time points stacked/overlaid), and **Timeline** (activity or proximity timeline for individual nodes) |
| **Animation** | D3-powered animated network using the `ndtv` package; plays through all time points to show the network's evolution as a continuous animation |

## Dataset

**Newcomb Fraternity Study** — loaded from `../shared/data/frat_graphs.rda`

| Object | Description |
|--------|-------------|
| `frat_n` | Named list of 15 `network` objects, one per weekly measurement |
| `frat_tnet` | `networkDynamic` object built from `frat_n` (used for `ndtv` animation) |

**Study context:** Theodore Newcomb tracked friendship nominations among 17 fraternity members at the University of Michigan over 15 consecutive weeks in Fall 1956. Each week, members ranked their top-3 friends. The resulting 15 directed, unweighted networks capture how social structure stabilized from an initially random rooming assignment into stable friendship cliques.

**Pre-computed globals** (built at startup in `global.R`):

| Object | Description |
|--------|-------------|
| `N_TIME_POINTS` | 15 |
| `MAX_TIME` | 14 (0-based upper bound for `networkDynamic`) |
| `net_stats` | Data frame with density, transitivity, reciprocity, node count, and edge count for all 15 time points |

The animation layout is computed once at startup via `ndtv::compute.animation(frat_tnet)` — this can take a few seconds but is shared across all sessions.

## File Structure

```
dynamic_nets/
├── app.R               # Entry point — sources global.R, ui/ui.R, server/server.R
├── global.R            # Package loading, data loading, networkDynamic construction,
│                       #   pre-computed stats, animation layout
├── ui/
│   ├── ui.R            # Assembles the full dashboardPage; defines all tab content
│   │                   #   as tagList objects (tab_stats, tab_snapshots,
│   │                   #   tab_multitime, tab_animation)
│   ├── ui_headbar.R    # Top navigation bar
│   └── ui_sidebar.R    # Sidebar: dataset info, time controls (single point
│                       #   or time window slider), graph appearance
└── server/
    └── server.R        # All server logic (single file): tab routing,
                        #   snapshot plots, filmstrip, prism, timeline, animation
```

> **Note:** Unlike the other apps, all dynamic_nets server logic lives in a single `server/server.R` file. This reflects the tighter coupling between views in this app — most outputs share the same time-indexed data and pre-computed objects.

## Running the App

```r
# From the SNA_App/ root directory:
shiny::runApp("dynamic_nets")

# Or open dynamic_nets/app.R in RStudio and click "Run App"
```

> The app prints a startup message to the console and a brief pause is expected while the animation layout computes.

### Required Packages

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",
  "ndtv", "tsna", "networkDynamic", "network", "sna",
  "ggplot2", "dplyr",
  "htmlwidgets", "htmltools", "here"
))
```

## How the Code Is Organized

**Time controls:** The sidebar provides two modes — a single time-point slider (`input$time_point`, 1-based display) and an optional time-window range slider (`input$time_window`, 0-based to match `networkDynamic`). A `checkboxInput("use_window", ...)` toggles between them using `conditionalPanel`.

**Stats tab:** `net_stats` is a pre-computed data frame. The stats tab reads `input$time_point` to select the row for the value boxes, and `input$stat_metric` to select the column for the line chart — no network recomputation needed at runtime.

**Snapshot tab:** Renders a `ggplot2` plot of `frat_n[[input$time_point]]` using the `network` / `sna` packages. Compare mode renders two plots side by side driven by `input$compare_t1` and `input$compare_t2`.

**Multi-Time tab:** Three `tabPanel`s inside a `tabsetPanel`:
- *Filmstrip* — a grid of all 15 snapshots using `gridExtra::grid.arrange()`
- *Time Prism* — overlaid/stacked plots for user-selected time points (`input$prism_times`)
- *Timeline* — node-level activity or proximity timeline (`input$timeline_type`)

**Animation tab:** Calls `ndtv::render.d3movie()` on `frat_tnet` and serves the resulting HTML widget via `renderUI`.

## Contributing

- New analysis views should be added as new `tabMenuItem` entries in `ui_sidebar.R` and new `tab_*` tag lists in `ui/ui.R`, with corresponding server logic in `server/server.R`
- If server logic grows large, split it into `<name>_server.R` files (following the pattern of the other apps) and source them from `server/server.R`
- Run `node scan.js dynamic_nets` from the `SNA_App/` root to generate an accessibility report for this app
