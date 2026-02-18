# Social Network Analysis Interactive App

An interactive Shiny application for teaching and learning social network analysis concepts through hands-on visualization and analysis.

## 📖 Overview

This application accompanies a Social Network Analysis textbook and provides an accessible, interactive platform for exploring network data, visualization techniques, and analytical methods. No advanced statistical knowledge or extensive coding experience is required to use this app.

## ✨ Features

The app is organized into nine comprehensive modules:

- **📊 Overview** - Introduction to social network analysis and current network properties
- **🔗 Networks** - Understanding network fundamentals, nodes, edges, and attributes
- **🎨 Visualization** - Interactive network visualization with customizable layouts and styling
- **🌐 Connectivity** - Analysis of network paths, components, and reachability
- **⭐ Centrality** - Identifying important nodes using degree, betweenness, closeness, and eigenvector centrality
- **👥 Communities** - Detecting and analyzing subgroups and clusters within networks
- **🔄 Assortativity** - Examining mixing patterns and homophily in networks
- **🎭 Roles** - Structural equivalence and role analysis
- **🎲 Simulation** - Generate and compare synthetic networks

## 📊 Included Datasets

The app includes several classic and contemporary social network datasets:

| Dataset | Description | Nodes | Type |
|---------|-------------|-------|------|
| **Florentine Families** | Marriage relationships between prominent Florentine families in 15th century Renaissance Italy | 16 | Undirected |
| **Moreno 5th Grade** | Friendship ties among 5th grade students collected by Jacob Moreno in 1934 | 33 | Directed |
| **Sampson Monks** | Friendship relationships among monks in a monastery | 18 | Directed |
| **Hartford Drug Users** | Network of drug users in Hartford, Connecticut with demographic attributes | 293 | Undirected |
| **Hi-Tech Managers** | Friendship network among managers in a high-tech company | 21 | Directed |
| **GitHub Network** | Collaboration network from GitHub developers | - | Directed |

## 🚀 Getting Started

### Prerequisites

This app requires R (version 4.0.0 or higher recommended) and the following R packages:

```r
# Core Shiny packages
install.packages("shiny")
install.packages("shinydashboard")
install.packages("shinyjs")

# Network analysis packages
install.packages("igraph")
install.packages("network")
install.packages("sna")
install.packages("intergraph")

# Visualization packages
install.packages("visNetwork")
install.packages("plotly")
install.packages("ggplot2")
install.packages("RColorBrewer")
install.packages("gridExtra")

# Data manipulation and display
install.packages("DT")
install.packages("dplyr")
install.packages("scales")

# Utilities
install.packages("here")
```

### Installation

1. Clone this repository:
```bash
git clone <your-repository-url>
cd SNA_App
```

2. Open R or RStudio and set the working directory to the app folder

3. Install required packages (see Prerequisites above)

### Running the App

You can run the app in several ways:

**Option 1: Using RStudio**
- Open `app.R` in RStudio
- Click the "Run App" button

**Option 2: Using R Console**
```r
shiny::runApp()
```

**Option 3: Specify the directory**
```r
shiny::runApp("path/to/SNA_App")
```

The app will open in your default web browser. For the best experience, use a modern browser like Chrome, Firefox, or Edge.

## 📁 Project Structure

```
SNA_App/
├── app.R                    # Main application entry point
├── global.R                 # Global configurations and dependencies
├── data/                    # Network datasets (.rda files)
│   ├── drugnet.rda
│   ├── github.rda
│   ├── gss_ego.rda
│   ├── hi_tech.rda
│   ├── ifm.rda
│   ├── moreno.rda
│   ├── sampson.rda
│   └── tradenets.rda
├── helpers/                 # Helper functions
│   ├── network_helpers.R   # Network manipulation utilities
│   ├── plot_helpers.R      # Plotting utilities
│   ├── ui_helpers.R        # UI component helpers
│   └── ui_styles.R         # Custom CSS and JavaScript
├── server/                  # Server-side logic (modular)
│   ├── server.R            # Main server function
│   ├── assortativity_server.R
│   ├── centrality_server.R
│   ├── communities_server.R
│   ├── connectivity_server.R
│   ├── networks_server.R
│   ├── overview_server.R
│   ├── roles_server.R
│   ├── simulation_server.R
│   └── visualization_server.R
└── ui/                      # User interface components (modular)
    ├── ui.R                # Main UI assembly
    ├── ui_header.R         # Dashboard header
    ├── ui_sidebar.R        # Navigation sidebar
    ├── assortativity_ui.R
    ├── centrality_ui.R
    ├── communities_ui.R
    ├── connectivity_ui.R
    ├── networks_ui.R
    ├── overview_ui.R
    ├── roles_ui.R
    ├── simulation_ui.R
    └── visualization_ui.R
```

## 🛠️ Technologies Used

- **R** - Statistical computing and graphics
- **Shiny** - Web application framework for R
- **shinydashboard** - Dashboard layout and components
- **igraph** - Network analysis and manipulation
- **visNetwork** - Interactive network visualization
- **plotly** - Interactive plots and charts
- **ggplot2** - Static graphics

## 🎨 Design

The app features NC State University branding with a custom red and black color scheme. The interface is built using the shinydashboard framework with a modular architecture for maintainability and scalability.

## 📝 Usage Tips

1. **Start Simple**: Begin with smaller datasets like "Hi-Tech Managers" or "Florentine Families" to understand the basic features
2. **Explore Interactively**: Click on nodes and edges in visualizations to see detailed information
3. **Customize Visualizations**: Adjust layout algorithms, colors, and node sizes to highlight different aspects
4. **Compare Metrics**: Use multiple centrality measures to get a comprehensive view of node importance
5. **Experiment with Simulation**: Generate random networks to understand how network structure affects properties

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page or submit a pull request.

## 📄 License

This project is part of an educational course on Social Network Analysis. Please contact the author for licensing information.

## 👥 Author

Developed for the Social Network Analysis course at NC State University.

## 🙏 Acknowledgments

- Classic network datasets from various sources in the SNA research community
- NC State University for branding and support
- The R community for excellent packages and tools

## 📧 Contact

For questions, suggestions, or collaboration opportunities, please contact the course instructor or open an issue in this repository.

---

**Quick Start Command:**
```r
# Install all dependencies and run the app
if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny, shinydashboard, shinyjs, igraph, network, sna, 
               intergraph, visNetwork, plotly, ggplot2, RColorBrewer, 
               gridExtra, DT, dplyr, scales, here)
shiny::runApp()
```
