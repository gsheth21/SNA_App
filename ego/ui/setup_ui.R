source(here::here("shared", "helpers", "ui_helpers.R"))

setup_ui <- tagList(

  tabBox(
    title = "Data Setup & Exploration",
    id = "setup_tabs",
    width = 12,

    # ── Tab 1: Data Overview ─────────────────────────────────────────────────
    tabPanel(
      title = "Data Overview",
      value = "setup_overview",
      icon = icon("info-circle"),

      fluidRow(
        box(
          title = "Dataset Summary",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("dataset_summary_ui")
        )
      ),

      fluidRow(
        box(
          title = "Egos Distribution",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          plotOutput("egos_distribution_plot", height = "400px")
        ),

        box(
          title = "Alters per Ego",
          width = 6,
          status = "primary",
          solidHeader = TRUE,
          uiOutput("alters_stats_ui")
        )
      )
    ),

    # ── Tab 2: Ego Attributes Table ──────────────────────────────────────────
    tabPanel(
      title = "Ego Attributes",
      value = "setup_ego_attributes",
      icon = icon("user"),

      fluidRow(
        box(
          title = "All Egos (N=288)",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          DTOutput("ego_attributes_table"),
          p(tags$small("Columns: ego_id, Female (0/1), Non-White (0/1), Age, Education, Sex, Race, Party ID, Religion"),
            style = "color: #888; margin-top: 10px;")
        )
      )
    ),

    # ── Tab 3: Alter Attributes Table ────────────────────────────────────────
    tabPanel(
      title = "Alter Attributes",
      value = "setup_alter_attributes",
      icon = icon("users"),

      fluidRow(
        box(
          title = "Long-Format Alters (N~1400)",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Showing all alters reshaped from wide to long format. Filter by ego_id or scroll through."),
            style = "color: #888; margin-bottom: 10px;"),
          DTOutput("alter_attributes_table")
        )
      )
    ),

    # ── Tab 4: Edgelist Table ────────────────────────────────────────────────
    tabPanel(
      title = "Alter-Alter Edges",
      value = "setup_edges",
      icon = icon("link"),

      fluidRow(
        box(
          title = "Edgelist: Alter-to-Alter Relationships",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(tags$small("Showing connections between alters with weights: 2=especially close, 1=know each other. Total strangers removed."),
            style = "color: #888; margin-bottom: 10px;"),
          DTOutput("edges_table")
        )
      )
    )
  )
)
