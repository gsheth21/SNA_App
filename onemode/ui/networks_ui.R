source(here::here("shared", "helpers", "ui_helpers.R"))

networks_ui <- tagList(

  tabBox(
    title = "Networks",
    id = "networks_tabs",
    width = 12,

    # ── Subtab 1 : Network Overview ──────────────────────────────────────────
    tabPanel(
      title = "Network Overview",
      value = "networks_overview",
      icon  = icon("network-wired"),

      # Row 1 — Network Type Badge + Loop Warning
      fluidRow(

        # Network Type Badge
        box(
          title  = "Network Type",
          width  = 4,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("network_type_badge")
        ),

        # Loop Warning + Simplify Button
        box(
          title  = "Loop Check",
          width  = 4,
          status = "warning",
          solidHeader = TRUE,
          uiOutput("loop_warning_ui")
        ),

        # Network Density
        box(
          title  = "Network Density",
          width  = 4,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("density_ui")
        )
      ),

      # Row 2 — Node/Edge Counts + Isolates + Pendants
      fluidRow(

        # Basic Counts
        box(
          title       = "Basic Counts",
          width       = 4,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("basic_counts_ui")
        ),

        # Isolates
        box(
          title       = "Isolates",
          width       = 4,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("isolates_ui")
        ),

        # Pendants
        box(
          title       = "Pendants",
          width       = 4,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("pendants_ui")
        )
      ),

      # Row 3 — Network Graph (ggraph default + interactive tab)
      fluidRow(
        box(
          title       = "Network Graph",
          width       = 12,
          status      = "primary",
          solidHeader = TRUE,

          tabsetPanel(
            id       = "networks_graph_tabs",
            selected = "ggraph",
            tabPanel(
              title = "ggraph",
              value = "ggraph",
              br(),
              withSpinner(plotOutput("networks_ggraph", height = "500px"), color = "#CC0000", type = 4)
            ),
            tabPanel(
              title = "Interactive",
              value = "interactive",
              br(),
              withSpinner(visNetworkOutput("networks_visplot", height = "500px"), color = "#CC0000", type = 4)
            )
          )
        )
      ),

      # Row 4 — Vertex Attributes + Edge Attributes
      fluidRow(

        # Vertex Attributes
        box(
          title       = "Vertex Attributes",
          width       = 6,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("vertex_attr_ui")
        ),

        # Edge Attributes
        box(
          title       = "Edge Attributes",
          width       = 6,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("edge_attr_ui")
        )
      )
    ),

    # ── Subtab 2 : Matrix View ───────────────────────────────────────────────
    tabPanel(
      title = "Matrix View",
      value = "networks_matrix",
      icon  = icon("table"),

      # # Directed network note (shown conditionally via server)
      # uiOutput("matrix_directed_note"),

      # # Dynamic inner tabsetPanel (one tab per numeric edge attr, or binary)
      # uiOutput("matrix_tabs_ui")

      fluidRow(
        box(
          title       = "Adjacency Matrix",
          width       = 12,
          status      = "primary",
          solidHeader = TRUE,
          uiOutput("matrix_directed_note"),
          uiOutput("matrix_tabs_ui")
        )
      )
    ),

    # ── Subtab 3 : Data Frames ───────────────────────────────────────────────
    tabPanel(
      title = "Data Frames",
      value = "networks_dataframes",
      icon  = icon("database"),

      # Vertex attributes table
      fluidRow(
        box(
          title       = "Vertex Attributes",
          width       = 12,
          status      = "primary",
          solidHeader = TRUE,
          DTOutput("vertex_attr_table")
        )
      ),

      # Edge list table
      fluidRow(
        box(
          title       = "Edge List & Edge Attributes",
          width       = 12,
          status      = "primary",
          solidHeader = TRUE,
          DTOutput("edge_attr_table")
        )
      )
    )
  )
)