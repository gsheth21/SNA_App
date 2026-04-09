create_sidebar <- function() {
  dashboardSidebar(
    width = 300,

    h3("Ego Network Analysis", id = "logo"),
    hr(),

    # ============================================================
    # SECTION 1: Ego Selection (dynamically built in server)
    # ============================================================
    h4("👤 Ego Selection", id = "heading"),
    uiOutput("ego_selector_ui"),

    # Ego profile summary (rendered dynamically)
    uiOutput("ego_profile_summary"),

    hr(),

    # ============================================================
    # SECTION 2: Graph Layers (collapsible, open by default)
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
    # SECTION 3: View Mode (Alters only vs With Ego)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("👁️ View Mode"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(
        style = "padding-left: 15px;",
        radioButtons(
          "view_mode",
          NULL,
          choices = c(
            "Alters Only (no ego)" = "alters_only",
            "With Ego (highlighted)" = "with_ego"
          ),
          selected = "alters_only"
        )
      )
    ),

    # ============================================================
    # SECTION 4: Layout Algorithm (collapsible, open by default)
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
            "Grid" = "grid"
          ),
          selected = "fr"
        )
      )
    ),

    # ============================================================
    # SECTION 5: Alter Appearance (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🟡 Alter Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
    div(
      style = "padding-left: 15px;",

      # Global settings
      strong("Global Settings", style = "font-size: 12px; color: #aaa;"),
      tags$br(), tags$br(),

      selectInput(
        "alter_color",
        "Alter Color:",
        choices = c(
          "Blue" = "#1f78b4",
          "Red (NC State)" = "#CC0000",
          "Green" = "#33a02c",
          "Orange" = "#ff7f00",
          "Purple" = "#6a3d9a",
          "Black" = "#000000"
        ),
        selected = "#1f78b4"
      ),
      
      selectInput(
        "alter_shape",
        "Alter Shape:",
        choices = c(
          "Dot" = "dot",
          "Square" = "square",
          "Triangle" = "triangle",
          "Diamond" = "diamond",
          "Star" = "star"
        ),
        selected = "dot"
      ),
      
      sliderInput("alter_size",  "Alter Size:",  min = 2,  max = 40, value = 10, step = 1),
      sliderInput("ego_size",    "Ego Size:",    min = 2,  max = 40, value = 15, step = 1),
      sliderInput("label_size",  "Label Size:",  min = 8,  max = 24, value = 12, step = 1),

      tags$br(),
      strong("Attribute Mapping", style = "font-size: 12px; color: #aaa;"),
      tags$br(), tags$br(),

      uiOutput("alter_attribute_controls")
    )
    ),

    # ============================================================
    # SECTION 6: Edge Appearance (collapsible, open by default)
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
          "Gray" = "#555555",
          "Black" = "#000000",
          "Red" = "#CC0000",
          "Blue" = "#1f78b4",
          "Green" = "#33a02c"
        ),
        selected = "#555555"
      ),

      selectInput(
        "edge_style",
        "Edge Style:",
        choices = c("Straight" = "straight", "Curved" = "curved"),
        selected = "straight"
      ),
      
      conditionalPanel(
        condition = "input.edge_style == 'curved'",
        sliderInput("curve_strength", "Curve Strength:",
                    min = 0.1, max = 1.0, value = 0.3, step = 0.1)
      ),
      
      sliderInput("edge_width",   "Edge Width:",   min = 0.5, max = 5, value = 1, step = 0.5),
      sliderInput("edge_opacity", "Edge Opacity:", min = 0.1, max = 1.0, value = 0.8, step = 0.1)
    )
    ),

    # ============================================================
    # SECTION 7: Edge Weights (collapsible, open by default)
    # ============================================================
    tags$button(
      class = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("⚖️ Edge Weights"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
    div(
      style = "padding-left: 15px;",
      selectInput(
        "weight_style",
        "Visualize Weights As:",
        choices = c(
          "None (uniform)" = "none",
          "Line Width" = "width",
          "Line Color" = "color"
        ),
        selected = "width"
      ),
      p(tags$small("Weights represent alter closeness: 2=especially close, 1=know each other"),
        style = "color: #888; margin-top: 10px; font-size: 11px;")
    )
    )
  )
}
