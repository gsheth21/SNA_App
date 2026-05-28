# Ego Network Analysis App

An interactive Shiny dashboard for exploring personal (ego) networks. This app uses data from the General Social Survey (GSS) to demonstrate the unique concepts and methods of ego network analysis — where the unit of analysis is an individual and their immediate social environment.

## What This App Does

An ego network consists of a **focal node (ego)** and all the people they name as contacts **(alters)**, plus the relationships between those alters. Unlike whole-network analysis, ego networks are collected through survey instruments and studied at the individual level.

This app lets students select any of 288 survey respondents, visualize their personal network, explore alter attributes, and compute ego-level structural measures.

## Modules (Tabs)

The app has two main sections, each with its own set of tabs:

### Data Setup & Exploration

| Tab | Description |
|-----|-------------|
| **Data Overview** | Dataset-level summary: total egos, distribution of network sizes, average number of alters per ego |
| **Ego Attributes** | Full table of all 288 egos with their demographic attributes (sex, race, age, education, party ID, religion) |
| **Alter Attributes** | Long-format table of all alters across all egos with their relationship attributes |

### Ego Network Analysis

| Tab | Description |
|-----|-------------|
| **Network Visualization** | Plot the selected ego's alter network using static (`ggraph`) or interactive (`visNetwork`) rendering; toggle between alters-only and with-ego views |
| **Ego Measures** | Structural measures for the selected ego: network size, density, homophily (EI index), and compositional statistics on alter attributes |

## Dataset

**GSS Ego Network Data** — loaded from `../shared/data/gss_ego.rda`

| Object | Description |
|--------|-------------|
| `gr.list` | Named list of igraph objects, one per ego — alters-only networks (no ego node) |
| `gr.list.ego` | Same list but with the ego node included and highlighted |
| `ego` | Data frame of ego-level attributes (N = 288 rows) |
| `alterlong` | Long-format data frame of alter attributes across all egos |

The GSS "Important Matters" name generator asks respondents to name up to 5 people they discuss important matters with. Alters are characterized by their relationship to ego and by perceived attributes (race, sex, closeness).

## File Structure

```
ego/
├── app.R               # Entry point — sources global.R, ui/ui.R, server/server.R
├── global.R            # Package loading, data loading, ego ID extraction,
│                       #   color palettes and layout defaults
├── ui/
│   ├── ui.R            # Assembles the full dashboardPage; sources all chapter UIs
│   ├── ui_header.R     # Top navigation bar
│   ├── ui_sidebar.R    # Sidebar: ego selector, ego profile summary,
│   │                   #   graph layers, view mode, layout controls
│   ├── setup_ui.R      # Data Setup section (Data Overview, Ego Attrs, Alter Attrs)
│   └── analysis_ui.R   # Analysis section (Network Visualization, Ego Measures)
└── server/
    ├── server.R            # Main server — tab routing, ego selection reactive
    ├── setup_server.R      # Data Overview, Ego Attributes, Alter Attributes logic
    └── analysis_server.R   # Network visualization and ego measures logic
```

## Running the App

```r
# From the SNA_App/ root directory:
shiny::runApp("ego")

# Or open ego/app.R in RStudio and click "Run App"
```

### Required Packages

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",
  "igraph", "visNetwork", "ggplot2", "ggraph", "graphlayouts",
  "RColorBrewer", "gridExtra",
  "DT", "dplyr", "tidyr", "scales", "purrr", "here"
))
```

## How the Code Is Organized

**Ego selection:** The sidebar renders a dynamic `selectInput` (via `uiOutput("ego_selector_ui")`) populated from the ego IDs detected in `gr.list`. Selecting an ego updates a reactive value `rv$ego_id` that all analysis outputs observe.

**View modes:** The sidebar's "View Mode" radio button toggles between `"alters_only"` (draws from `gr.list`) and `"with_ego"` (draws from `gr.list.ego`). The ego node is styled distinctly (larger, different color) in the with-ego view.

**Profile summary:** A compact profile card (`uiOutput("ego_profile_summary")`) renders in the sidebar, showing the selected ego's demographic attributes and alter count — updating live as egos are switched.

**Server split:** `setup_server.R` handles the dataset-level tabs (no ego-specific reactivity). `analysis_server.R` handles the per-ego network plots and measures.

## Contributing

- Ego-specific analysis tabs go in `analysis_ui.R` and `analysis_server.R`
- Dataset-level exploration tabs go in `setup_ui.R` and `setup_server.R`
- New ego-level measures (e.g., brokerage, constraint) should be added to `analysis_server.R` and exposed in the **Ego Measures** tab
- Run `node scan.js ego` from the `SNA_App/` root to generate an accessibility report for this app
