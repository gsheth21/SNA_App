source(here::here("shared", "helpers", "ui_helpers.R"))

analysis_ui <- tagList(

  tabBox(
    title = "Ego Network Analysis",
    id = "analysis_tabs",
    width = 12,

    # ── Tab 1: Network Visualization ─────────────────────────────────────────
    tabPanel(
      title = "Network Visualization",
      value = "analysis_network",
      icon = icon("project-diagram"),

      fluidRow(
        box(
          title = "Alter Network Graph",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Use sidebar to toggle view mode (alters only vs with ego), layout, colors, etc."),
            style = "color: #888; margin-bottom: 10px;"),
          tabsetPanel(
            id = "analysis_graph_tabs", selected = "ggraph",
            tabPanel("ggraph", value = "ggraph",
              br(),
              withSpinner(plotOutput("analysis_ggraph", height = "600px"),
                          color = "#CC0000", type = 4)
            ),
            tabPanel("Interactive", value = "interactive",
              br(),
              withSpinner(visNetworkOutput("analysis_visplot", height = "600px"),
                          color = "#CC0000", type = 4)
            )
          )
        )
      ),

      fluidRow(
        box(
          title = "Alter Attributes",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("analysis_alter_attr_ui")
        ),

        box(
          title = "Edge Attributes",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Alter-to-alter relationship weights (closeness perception)"),
            style = "color: #888; margin-bottom: 10px;"),
          uiOutput("analysis_edge_attr_ui")
        )
      )
    ),

    # ── Tab 2: Ego Profile ───────────────────────────────────────────────────
    tabPanel(
      title = "Ego Profile",
      value = "analysis_ego_profile",
      icon = icon("address-card"),

      fluidRow(
        box(
          title = "Selected Ego Demographics",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("ego_demographics_ui")
        ),

        box(
          title = "Ego Network Composition",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("ego_composition_ui")
        )
      ),

      fluidRow(
        box(
          title = "Selected Ego's Alters",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("All alters for this ego with their attributes"),
            style = "color: #888; margin-bottom: 10px;"),
          DTOutput("ego_alters_table")
        )
      )
    ),

    # ── Tab 3: Network Metrics ───────────────────────────────────────────────
    tabPanel(
      title = "Network Metrics",
      value = "analysis_metrics",
      icon = icon("chart-bar"),

      fluidRow(
        box(
          title = "Three-Level Metrics",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Network statistics analyzed at three nested levels: Ego (demographics), Alters (composition), and Edges (structure)"),
            style = "color: #888; margin-bottom: 15px;")
        )
      ),

      fluidRow(
        box(
          title = "Ego-Level (Demographics)",
          width = 4,
          status = "info",
          solidHeader = TRUE,
          uiOutput("metrics_ego_level_ui")
        ),

        box(
          title = "Alter-Level (Composition)",
          width = 4,
          status = "info",
          solidHeader = TRUE,
          uiOutput("metrics_alter_level_ui")
        ),

        box(
          title = "Edge-Level (Structure)",
          width = 4,
          status = "info",
          solidHeader = TRUE,
          uiOutput("metrics_edge_level_ui")
        )
      )
    ),

    # ── Tab 4: Statistical Summary ───────────────────────────────────────────
    tabPanel(
      title = "Statistical Summary",
      value = "analysis_stats",
      icon = icon("chart-line"),

      fluidRow(
        box(
          title = "Bivariate Analysis: Does Ego Gender Affect Alter Composition?",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Testing association between ego gender and network composition metrics across all 288 egos"),
            style = "color: #888; margin-bottom: 15px;"),
          tabsetPanel(
            tabPanel(
              "ANOVA Results",
              verbatimTextOutput("anova_results_ui")
            ),
            tabPanel(
              "Mean Comparison",
              DTOutput("mean_comparison_table")
            ),
            tabPanel(
              "Visualization",
              plotOutput("gender_effect_plot", height = "500px")
            )
          )
        )
      )
    )
  )
)
