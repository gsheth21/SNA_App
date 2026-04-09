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
      choices = {
        ds <- Filter(function(d) "overview" %in% d$chapters, dataset_registry)
        setNames(names(ds), sapply(ds, `[[`, "label"))
      },
      selected = chapter_defaults[["overview"]]$dataset
    ),

    uiOutput("network_object_ui"),

    # ============================================================
    # SECTION 2: Graph Layers  (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🔲 Graph Layers"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(
        style = "padding-left: 15px;",
        checkboxGroupInput(
          "layer_selection",
          NULL,
          choices  = c("Edges" = "edges", "Labels" = "labels"),
          selected = c("edges", "labels")
        )
      )
    ),

    # ============================================================
    # SECTION 3: Layout Algorithm  (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("📐 Layout Algorithm"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(
        style = "padding-left: 15px;",
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
          selected = "stress"
        )
      )
    ),

    # ============================================================
    # SECTION 4: Node Appearance  (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🟡 Node Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
    div(
      style = "padding-left: 15px;",

      # --- Global (static) settings ---
      strong("Global Settings", style = "font-size: 12px; color: #aaa;"),
      tags$br(), tags$br(),

      selectInput(
        "node_color",
        "Node Color:",
        choices = c(
          "Red (NC State)"  = "#CC0000",
          "Black"           = "#000000",
          "Blue"            = "#1f78b4",
          "Green"           = "#33a02c",
          "Orange"          = "#ff7f00",
          "Purple"          = "#6a3d9a"
        ),
        selected = "#CC0000"
      ),
      selectInput(
        "node_shape",
        "Node Shape:",
        choices = c(
          "Dot"          = "dot",
          "Square"       = "square",
          "Triangle"     = "triangle",
          "Diamond"      = "diamond",
          "Star"         = "star"
        ),
        selected = "dot"
      ),
      sliderInput("node_size",  "Node Size:",  min = 2,  max = 40, value = 10, step = 1),
      sliderInput("label_size", "Label Size:", min = 8,  max = 24, value = 12, step = 1),

      tags$br(),
      # --- Attribute-based (aes) settings ---
      strong("Attribute Mapping (aes)", style = "font-size: 12px; color: #aaa;"),
      tags$br(), tags$br(),

      uiOutput("attribute_controls"),
      uiOutput("attribute_legend_ui")
    )
    ),

    # ============================================================
    # SECTION 5: Edge Appearance  (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("➡️ Edge Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
    div(
      style = "padding-left: 15px;",

      selectInput(
        "edge_color",
        "Edge Color:",
        choices = c(
          "Gray"   = "#555555",
          "Black"  = "#000000",
          "Red"    = "#CC0000",
          "Blue"   = "#1f78b4",
          "Green"  = "#33a02c"
        ),
        selected = "#555555"
      ),

      selectInput(
        "edge_style",
        "Edge Style:",
        choices  = c("Straight" = "straight", "Curved" = "curved"),
        selected = "straight"
      ),
      conditionalPanel(
        condition = "input.edge_style == 'curved'",
        sliderInput("curve_strength", "Curve Strength:",
                    min = 0.1, max = 1.0, value = 0.3, step = 0.1)
      ),
      checkboxInput("hide_arrows", "Hide Arrows", value = FALSE),
      sliderInput("edge_width",   "Edge Width:",   min = 0.5, max = 5,   value = 1,   step = 0.5),
      sliderInput("edge_opacity", "Edge Opacity:", min = 0.1, max = 1.0, value = 0.5, step = 0.1)
    )
    ),

    # ============================================================
    # SECTION 6: Edge Weights  (collapsible, closed by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle",
      onclick = "toggleSidebarSection(this)",
      tags$span("⚖️ Edge Weights"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body", style = "display: none;",
    div(
      style = "padding-left: 15px;",
      selectInput(
        "weight_style",
        "Visualize Weights As:",
        choices = c(
          "None (ignore weights)"  = "none",
          "Line Width"             = "width",
          "Dashed vs. Solid"       = "linetype",
          "Color"                  = "color",
          "Reciprocity (directed only)"    = "reciprocity"
        ),
        selected = "none"
      )
    )
    )
  )
}