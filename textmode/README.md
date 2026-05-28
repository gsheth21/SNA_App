# Text Network Analysis App

An interactive Shiny dashboard for building and analyzing word co-occurrence networks from text. This app uses the Declaration of Independence (1776) to walk students through the complete text-network pipeline — from raw document to clustered semantic communities — following the corresponding textbook chapter.

## What This App Does

A text network represents a document as a graph where **nodes are words** and **edges connect words that co-occur in the same sentence**. Edge weight records how many sentences two words share. Rather than just counting word frequencies, this approach reveals how concepts are organizationally connected — which words bridge different themes, which form tight semantic clusters, and which are central to the document's argument.

The app demonstrates every step of this pipeline interactively, letting students adjust stopword lists and see how those decisions propagate through the entire analysis.

## Modules (Tabs)

| Tab | Description |
|-----|-------------|
| **Overview** | Introduction to text networks, the co-occurrence model, and a guide to using the app; background on the Declaration of Independence as a teaching text |
| **Text Prep** | Sentence tokenization, word tokenization, stopword removal (standard + custom), and frequency tables; shows the effect of each preprocessing decision |
| **Co-occurrence** | Word-pair co-occurrence counts; ranked table of the top N pairs by shared sentence count; adjustable via the "Top N Pairs" sidebar slider |
| **Network** | igraph object summary — node count, edge count, density, average degree — for the filtered co-occurrence network |
| **Centrality** | Degree and betweenness centrality rankings; bar charts and tables of the most connected and most broker-like words |
| **Visualization** | Static (`ggraph`) and interactive (`visNetwork`) plots of the word network; node size encodes degree centrality |
| **Clusters** | Community detection on the word network; semantic cluster membership revealed through color-coded plots and tables |

## Dataset

**Declaration of Independence (1776)** — hardcoded in `global.R` as `declaration_text`.

The text is split into 14 sentences covering approximately 400 content tokens after stopword removal. This compact size makes it ideal for teaching: the network is small enough to visualize clearly, yet rich enough to show meaningful structure (the Preamble cluster, the Grievances cluster, the Declaration cluster).

### Default Stopwords

The app applies the standard tidytext English stopword list plus a set of custom stops defined in `global.R`:

```r
default_custom_stops <- c("us", "among", "shall", "may", "one")
```

Users can add or remove custom stopwords via the sidebar text area; changes update all downstream tabs reactively.

## File Structure

```
textmode/
├── app.R               # Entry point — sources global.R, ui/ui.R, server/server.R
├── global.R            # Package loading, declaration text, default custom stopwords
├── ui/
│   ├── ui.R            # Assembles the full dashboardPage; sources all chapter UIs
│   ├── ui_header.R     # Top navigation bar
│   ├── ui_sidebar.R    # Sidebar: dataset info, extra stopwords input,
│   │                   #   top-N-pairs slider, layout algorithm, node appearance
│   ├── overview_ui.R
│   ├── textprep_ui.R
│   ├── pairs_ui.R
│   ├── network_ui.R
│   ├── centrality_ui.R
│   ├── viz_ui.R
│   └── clusters_ui.R
└── server/
    ├── server.R            # Main server — tab routing, core reactive pipeline
    ├── overview_server.R
    ├── textprep_server.R
    ├── pairs_server.R
    ├── network_server.R
    ├── centrality_server.R
    ├── viz_server.R
    └── clusters_server.R
```

## Running the App

```r
# From the SNA_App/ root directory:
shiny::runApp("textmode")

# Or open textmode/app.R in RStudio and click "Run App"
```

### Required Packages

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyjs", "shinycssloaders",
  "igraph", "visNetwork", "ggraph", "ggplot2", "graphlayouts",
  "ggrepel", "RColorBrewer", "plotly",
  "tidytext", "widyr",
  "DT", "dplyr", "tidyr", "stringr", "tibble", "scales", "here"
))
```

## How the Code Is Organized

**Reactive pipeline:** All downstream tabs depend on a single pipeline defined in `server.R`:

1. `tokens_reactive()` — tokenizes `declaration_text`, removes standard stopwords, removes user-supplied custom stops from `input$extra_stops`
2. `pairs_reactive()` — calls `widyr::pairwise_count()` on the tokens, filtered to the top `input$n_pairs` pairs by count
3. `graph_reactive()` — builds an igraph object from the filtered pairs, with `weight` = co-occurrence count

Every chapter server file subscribes to `graph_reactive()` (or `tokens_reactive()` / `pairs_reactive()` for earlier-pipeline tabs).

**Sidebar reactivity:** Changes to `input$extra_stops` or `input$n_pairs` invalidate `tokens_reactive()` and `pairs_reactive()` respectively, which cascade through all downstream reactive expressions and re-render every output automatically.

## Contributing

- To add a new analysis tab, create `<name>_ui.R` and `<name>_server.R`, source them in `ui/ui.R` and `server/server.R`, and add the menu item to `ui_sidebar.R`
- To use a different text, replace `declaration_text` in `global.R` — the entire pipeline is text-agnostic
- Run `node scan.js textmode` from the `SNA_App/` root to generate an accessibility report for this app
