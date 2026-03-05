# source(here::here("helpers", "ui_helpers.R"))

# networks_ui <- tagList(
#   # tabName = "networks",
  
#   # Work in Progress Box
#   fluidRow(
#     create_wip_box(
#       chapter_name = "Networks",
#       topics = c(
#         "Network data structures (edgelists, matrices, igraph objects)",
#         "Understanding nodes and edges",
#         "Node and edge attributes",
#         "Network properties (size, density, components)",
#         "Data import and export",
#         "Network data manipulation"
#       ),
#       coming_soon_text = "🚧 This chapter is under development!"
#     )
#   ),
  
#   # Preview: Data Table (functional)
#   fluidRow(
#     box(
#       title = "📊 Network Data Preview",
#       width = 12,
#       solidHeader = TRUE,
#       status = "primary",
#       radioButtons(
#         "data_view",
#         "View:",
#         choices = c("Edgelist", "Adjacency Matrix", "Nodes"),
#         selected = "Edgelist",
#         inline = TRUE
#       ),
#       DTOutput("data_table")
#     )
#   ),
  
#   # Download options
#   fluidRow(
#     box(
#       title = "💾 Download Network Data",
#       width = 12,
#       solidHeader = TRUE,
#       downloadButton("download_csv", "CSV", class = "btn-danger"),
#       downloadButton("download_excel", "Excel", class = "btn-danger"),
#       downloadButton("download_rdata", "R Data File", class = "btn-danger")
#     )
#   )
# )


source(here::here("helpers", "ui_helpers.R"))

networks_ui <- tagList(

  tabsetPanel(
    id = "networks_tabs",
    type = "tabs",

    # ── Subtab 1 : Network Overview ──────────────────────────────────────────
    tabPanel(
      title = "Network Overview",
      value = "networks_overview",

      br(),

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

      # Row 3 — visNetwork Plot
      fluidRow(
        box(
          title       = "Network Graph",
          width       = 12,
          status      = "primary",
          solidHeader = TRUE,

          # Layout dropdown
          fluidRow(
            column(
              width = 3,
              selectInput(
                inputId  = "networks_layout",
                label    = "Layout Algorithm",
                choices  = c(
                  "Force-directed (Fruchterman-Reingold)" = "layout_with_fr",
                  "Kamada-Kawai"                          = "layout_with_kk",
                  "Nicely (auto)"                         = "layout_nicely",
                  "Circle"                                = "layout_in_circle",
                  "Random"                                = "layout_randomly"
                ),
                selected = "layout_nicely"
              )
            )
          ),

          visNetworkOutput("networks_visplot", height = "500px")
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

      br(),

      # Directed network note (shown conditionally via server)
      uiOutput("matrix_directed_note"),

      # Dynamic inner tabsetPanel (one tab per numeric edge attr, or binary)
      uiOutput("matrix_tabs_ui")
    ),

    # ── Subtab 3 : Data Frames ───────────────────────────────────────────────
    tabPanel(
      title = "Data Frames",
      value = "networks_dataframes",

      br(),

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