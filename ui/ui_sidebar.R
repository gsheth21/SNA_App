create_sidebar <- function() {
  dashboardSidebar(
    width = 300,

    h3("One-Mode Network Analysis", id = "logo"),
    hr(),

    # Dataset Selection 
    h4("📊 Dataset Selection", id = "heading"),
    selectInput(
      "dataset",
      "Select Dataset:",
      choices = c(
        # "High Tech Managers" = "hi_tech",
        "Marriage Network" = "ifm"
        # "Moreno" = "moreno",
        # "Sampson's Monks" = "sampson",
        # "Hartford Drug Users" = "drugnet",
        # "Smith & White Classic Trades" = "tradenets",
        # "GitHub Network" = "github",
        # "General Social Survey Network" = "gss",
        # "General Social Survey EgoNet" = "gss_ego"
      ),
      selected = "ifm"
    ),

    hr(),

    # ============================================================
    # SECTION 2: Network Type
    # ============================================================
    h4("🔗 Network Properties", id = "heading"),
    div(
      style = "padding-left: 15px;",
      checkboxInput("directed", "Directed", value = FALSE),
      checkboxInput("weighted", "Weighted", value = FALSE)
    ),

    hr(),

    # ============================================================
    # SECTION 3: Visualization Controls
    # ============================================================
    h4("🎨 Layout Algorithm", id = "heading"),
    selectInput(
      "layout",
      NULL,
      choices = c(
        "Fruchterman-Reingold" = "fr",
        "Kamada-Kawai" = "kk",
        "Stress" = "stress",
        "Circle" = "circle",
        "Tree" = "tree",
        "Grid" = "grid",
        "Bipartite" = "bipartite",
        "MDS" = "mds",
        "Random" = "randomly"
      ),
      selected = "fr"
    ),

    hr(),

    h4("🎨 Visual Styling", id = "heading"),
    sliderInput("node_size", "Node Size", min = 2, max = 20, value = 10, step = 1),
    sliderInput("edge_width", "Edge Width", min = 0.5, max = 5, value = 1, step = 0.5),
    sliderInput("node_opacity", "Node Opacity", min = 0, max = 1, value = 0.8, step = 0.1),
    sliderInput("edge_opacity", "Edge Opacity", min = 0, max = 1, value = 0.5, step = 0.1),
    sliderInput("label_size", "Label Size", min = 8, max = 16, value = 12, step = 1),

    hr(),

    # ============================================================
    # SECTION 4: Node Attributes
    # ============================================================
    h4("📈 Node Attributes", id = "heading"),
    uiOutput("attribute_controls"),

    hr(),

    # ============================================================
    # SECTION 5: Highlight Options
    # ============================================================
    h4("📈 Highlight Options", id = "heading"),
    div(
      style = "padding-left: 15px;",
      checkboxInput("highlight_isolates", "Highlight Isolates", value = FALSE),
      checkboxInput("highlight_bridges", "Highlight Bridges", value = FALSE),
      checkboxInput("highlight_cutpoints", "Highlight Cutpoints", value = FALSE),
      checkboxInput("show_components", "Show Components", value = FALSE)
    ),

    hr(),

    # ============================================================
    # SECTION 6: Simulation Controls (conditional)
    # ============================================================
    conditionalPanel(
      condition = "input.current_tab == 'simulation'",
      h4("🎲 Network Generation", id = "heading"),
      selectInput(
        "sim_model",
        "Model Type:",
        choices = c(
          "Erdős-Rényi Random" = "erdos",
          "Small World" = "smallworld",
          "Preferential Attachment" = "barabasi",
          "Built-in Types" = "builtin",
          "Random Walk" = "randomwalk"
        ),
        selected = "erdos"
      ),
      numericInput("random_seed", "Random Seed:", value = 123, min = 1, max = 10000),

      h4("🎲 Model Parameters", id = "heading"),
      uiOutput("simulation_params")
    )
  )
}