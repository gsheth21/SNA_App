create_sidebar <- function() {
  dashboardSidebar(
    width = 300,
    
    # ============================================================
    # SECTION 1: Data Selection
    # ============================================================
    h4("📊 Dataset Selection", style = "padding-left: 15px;"),
    selectInput(
      "dataset",
      "Select Dataset:",
      choices = c(
        "Hi-Tech Managers (ifm)" = "ifm",
        "Hartford Drug Users (drugnet)" = "drugnet",
        "GitHub Network (github)" = "github",
        "Zachary's Karate Club (karate)" = "karate",
        "Florentine Families - Marriage (flomarriage)" = "flomarriage",
        "Florentine Families - Business (flobusiness)" = "flobusiness",
        "Sampson's Monks (sampson)" = "sampson",
        "Simulated High School (faux.mesa.high)" = "faux.mesa.high"
      ),
      selected = "ifm"
    ),
    
    hr(),
    
    # ============================================================
    # SECTION 2: Network Type
    # ============================================================
    h4("🔗 Network Properties", style = "padding-left: 15px;"),
    div(
      style = "padding-left: 15px;",
      checkboxInput("directed", "Directed", value = FALSE),
      checkboxInput("weighted", "Weighted", value = FALSE)
    ),
    
    hr(),
    
    # ============================================================
    # SECTION 3: Visualization Controls
    # ============================================================
    h4("🎨 Layout Algorithm", style = "padding-left: 15px;"),
    selectInput(
      "layout",
      NULL,
      choices = c(
        "Stress (default)" = "stress",
        "Fruchterman-Reingold" = "fr",
        "Kamada-Kawai" = "kk",
        "Circle" = "circle",
        "Nicely" = "nicely",
        "Grid" = "grid",
        "Sphere" = "sphere"
      ),
      selected = "stress"
    ),
    
    h4("🎨 Visual Styling", style = "padding-left: 15px;"),
    sliderInput("node_size", "Node Size", min = 2, max = 20, value = 10, step = 1),
    sliderInput("edge_width", "Edge Width", min = 0.5, max = 5, value = 1, step = 0.5),
    sliderInput("node_opacity", "Node Opacity", min = 0, max = 1, value = 0.8, step = 0.1),
    sliderInput("edge_opacity", "Edge Opacity", min = 0, max = 1, value = 0.5, step = 0.1),
    sliderInput("label_size", "Label Size", min = 8, max = 16, value = 12, step = 1),
    
    hr(),
    
    # ============================================================
    # SECTION 4: Node Attributes
    # ============================================================
    h4("📈 Node Attributes", style = "padding-left: 15px;"),
    uiOutput("attribute_controls"),
    
    hr(),
    
    # ============================================================
    # SECTION 5: Highlight Options
    # ============================================================
    h4("📈 Highlight Options", style = "padding-left: 15px;"),
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
      h4("🎲 Network Generation", style = "padding-left: 15px;"),
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
      
      h4("🎲 Model Parameters", style = "padding-left: 15px;"),
      uiOutput("simulation_params")
    )
  )
}