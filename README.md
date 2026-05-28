# Social Network Analysis — Interactive Shiny Apps

A suite of five interactive Shiny dashboards for teaching and learning social network analysis. Each app corresponds to a chapter (or chapter group) in the accompanying SNA textbook and provides a hands-on, point-and-click environment for exploring real-world network data — no prior R experience required.

## Apps

| App | Directory | Topic | Dataset(s) |
|-----|-----------|-------|------------|
| **One-Mode Networks** | [`onemode/`](onemode/) | Classic SNA: connectivity, centrality, communities, roles, simulation | Florentine Families, Moreno, Sampson, Hi-Tech, Hartford Drug Users, GitHub, Trade Networks |
| **Two-Mode Networks** | [`twomode/`](twomode/) | Bipartite networks, affiliation matrices, projections | Grime music (artists × songs) |
| **Ego Networks** | [`ego/`](ego/) | Personal networks, ego-level measures, alter attributes | GSS "Important Matters" survey (N = 288) |
| **Text Networks** | [`textmode/`](textmode/) | Word co-occurrence networks, NLP pipeline, semantic communities | Declaration of Independence (1776) |
| **Dynamic Networks** | [`dynamic_nets/`](dynamic_nets/) | Longitudinal networks, time-series statistics, animation | Newcomb Fraternity Study (15 weeks, 1956) |

Each app has its own README with a full description, module guide, and contributor notes:
- [onemode/README.md](onemode/README.md)
- [twomode/README.md](twomode/README.md)
- [ego/README.md](ego/README.md)
- [textmode/README.md](textmode/README.md)
- [dynamic_nets/README.md](dynamic_nets/README.md)

## Repository Structure

```
SNA_App/
├── onemode/            # One-mode network analysis app
│   ├── app.R
│   ├── global.R
│   ├── ui/
│   └── server/
├── twomode/            # Two-mode (bipartite) network analysis app
│   ├── app.R
│   ├── global.R
│   ├── ui/
│   └── server/
├── ego/                # Ego network analysis app
│   ├── app.R
│   ├── global.R
│   ├── ui/
│   └── server/
├── textmode/           # Text network analysis app
│   ├── app.R
│   ├── global.R
│   ├── ui/
│   └── server/
├── dynamic_nets/       # Dynamic network analysis app
│   ├── app.R
│   ├── global.R
│   ├── ui/
│   └── server/
├── shared/
│   ├── data/           # All .rda dataset files (shared across apps)
│   └── helpers/        # Shared R helper functions
│       ├── network_helpers.R
│       ├── ggraph_helpers.R
│       ├── plot_helpers.R
│       └── ui_helpers.R
├── www/
│   ├── styles.css      # Shared CSS (NC State theme)
│   └── script.js       # Shared JavaScript (sidebar toggle, etc.)
├── deploy.R            # shinyapps.io deployment script
├── scan.js             # Accessibility scanner (single app)
└── scan_all.js         # Accessibility scanner (all apps)
```

## Running an App

Each app is self-contained and launched from the `SNA_App/` root directory:

```r
# Run any app by name:
shiny::runApp("onemode")
shiny::runApp("twomode")
shiny::runApp("ego")
shiny::runApp("textmode")
shiny::runApp("dynamic_nets")
```

Or open the app's `app.R` in RStudio and click **Run App**.

## Prerequisites

R ≥ 4.0.0. Install all packages needed across all five apps with:

```r
install.packages(c(
  # Shiny framework
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",

  # One-mode / general network analysis
  "igraph", "network", "sna", "intergraph",

  # Dynamic networks
  "ndtv", "tsna", "networkDynamic",

  # Visualization
  "visNetwork", "ggplot2", "ggraph", "graphlayouts",
  "plotly", "RColorBrewer", "gridExtra", "patchwork", "ggrepel",

  # Text analysis (textmode app)
  "tidytext", "widyr", "stringr", "tibble",

  # Data manipulation & display
  "DT", "dplyr", "tidyr", "scales", "purrr",

  # Utilities
  "here", "htmlwidgets", "htmltools"
))
```

## Datasets

All datasets are stored as `.rda` files in `shared/data/` and loaded by individual apps via `global.R`.

| File | Objects | Used by | Description |
|------|---------|---------|-------------|
| `ifm.rda` | `ifm` | onemode | Florentine Families marriage network — 16 nodes, undirected |
| `moreno.rda` | `moreno` | onemode | Moreno 5th-grade friendship network — 33 nodes, undirected |
| `sampson.rda` | `sampson` | onemode | Sampson's Monks — 18 nodes, undirected |
| `github.rda` | `github` | onemode | GitHub collaboration network — 174 nodes, undirected weighted |
| `drugnet.rda` | `drug_connect`, `drugnet` | onemode | Hartford Drug Users — 193/293 nodes, directed |
| `hi_tech.rda` | `htf`, `hta`, `htr` | onemode | Hi-Tech Managers (friendship/advice/reporting) — 21 nodes, directed |
| `tradenets.rda` | `c`,`d`,`f`,`m`,`mg` | onemode | International Trade Networks — 24 nodes, directed |
| `grime.rda` | `artist_track_edge`, `artist_track_adj` | twomode | Grime artists × songs bipartite network |
| `gss_ego.rda` | `gr.list`, `gr.list.ego`, `ego`, `alterlong` | ego | GSS ego networks — 288 respondents |
| `gss.rda` | — | *(reserved)* | GSS whole-network supplement |
| `frat_graphs.rda` | `frat_n` | dynamic_nets | Newcomb Fraternity — 15 weekly directed networks, 17 nodes |
| `bali.rda` | — | *(reserved)* | Bali terrorist network |

## Design

All apps share a consistent NC State University visual identity: red (`#CC0000`) and black, implemented through `www/styles.css`. The sidebar in each app uses a collapsible-section pattern driven by `www/script.js` and the `shinyjs` package.

## Accessibility

Each app has been scanned with axe-core. Reports are in `axe-report-<app>.json` / `axe-summary-<app>.txt`. To re-run a scan:

```bash
# From SNA_App/ directory (requires Node.js):
node scan.js onemode
node scan_all.js        # scans all five apps
```

## Deployment

Use `deploy.R` to publish any app to [shinyapps.io](https://www.shinyapps.io/). The script checks for `rsconnect` configuration, verifies required packages, and deploys the target app directory.

## Contributing

- Each app is independent — changes to one app do not affect the others
- Shared utilities (helpers, CSS, JS, datasets) live in `shared/` and `www/`
- Follow the existing file-naming convention: `<chapter>_ui.R` / `<chapter>_server.R`
- See the individual app READMEs for app-specific contribution notes

## License

Educational use. Developed for the Social Network Analysis course at NC State University. Contact the course instructor for licensing information.

## Acknowledgments

- Classic SNA datasets from the network science research community
- NC State University for branding and institutional support
- The R community for `igraph`, `ggraph`, `ndtv`, `tidytext`, and the broader Shiny ecosystem
