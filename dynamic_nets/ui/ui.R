source(here::here("dynamic_nets", "ui", "ui_headbar.R"))
source(here::here("dynamic_nets", "ui", "ui_sidebar.R"))

ui <- dashboardPage(
  skin = "red",

  header  = create_header(),
  sidebar = create_sidebar(),

  body = dashboardBody(
    useShinyjs(),

    tags$head(
      includeCSS(here::here("www", "styles.css")),
      includeScript(here::here("www", "script.js"))
    ),

    uiOutput("tab_content")
  )
)

# ── Tab content definitions (sourced at startup, rendered by server) ───────────

tab_stats <- tagList(
  fluidRow(
    valueBoxOutput("stat_density",      width = 3),
    valueBoxOutput("stat_transitivity", width = 3),
    valueBoxOutput("stat_reciprocity",  width = 3),
    valueBoxOutput("stat_edges",        width = 3)
  ),
  fluidRow(
    box(
      title       = "Network Metrics Over Time",
      width       = 12,
      status      = "primary",
      solidHeader = TRUE,
      fluidRow(
        column(3,
          selectInput(
            "stat_metric",
            "Metric to plot:",
            choices = c(
              "Density"      = "density",
              "Transitivity" = "transitivity",
              "Reciprocity"  = "reciprocity",
              "Edge Count"   = "e_count",
              "Node Count"   = "v_count"
            ),
            selected = "density"
          )
        )
      ),
      withSpinner(
        plotOutput("stats_lineplot", height = "360px"),
        color = "#CC0000", type = 4
      )
    )
  )
)

tab_snapshots <- tagList(
  fluidRow(
    box(
      width       = 12,
      status      = "primary",
      solidHeader = FALSE,
      checkboxInput("compare_mode", "Compare two time points side by side", value = FALSE)
    )
  ),
  conditionalPanel(
    condition = "!input.compare_mode",
    fluidRow(
      box(
        title       = uiOutput("snapshot_title"),
        width       = 12,
        status      = "primary",
        solidHeader = TRUE,
        withSpinner(
          plotOutput("snapshot_single", height = "480px"),
          color = "#CC0000", type = 4
        )
      )
    )
  ),
  conditionalPanel(
    condition = "input.compare_mode",
    fluidRow(
      column(6,
        box(
          title       = "Time Point A",
          width       = NULL,
          status      = "primary",
          solidHeader = TRUE,
          sliderInput("compare_t1", NULL,
                      min = 1, max = N_TIME_POINTS, value = 1, step = 1),
          withSpinner(
            plotOutput("snapshot_compare_a", height = "400px"),
            color = "#CC0000", type = 4
          )
        )
      ),
      column(6,
        box(
          title       = "Time Point B",
          width       = NULL,
          status      = "primary",
          solidHeader = TRUE,
          sliderInput("compare_t2", NULL,
                      min = 1, max = N_TIME_POINTS, value = 8, step = 1),
          withSpinner(
            plotOutput("snapshot_compare_b", height = "400px"),
            color = "#CC0000", type = 4
          )
        )
      )
    )
  )
)

tab_multitime <- tagList(
  tabsetPanel(
    id = "multitime_tabs",

    tabPanel(
      title = "Filmstrip",
      value = "filmstrip",
      br(),
      tags$p(
        style = "color: #666; font-size: 13px;",
        "Each panel shows the network structure at one time point. ",
        "Useful for spotting structural shifts across the semester."
      ),
      withSpinner(
        plotOutput("plot_filmstrip", height = "520px"),
        color = "#CC0000", type = 4
      )
    ),

    tabPanel(
      title = "Time Prism",
      value = "prism",
      br(),
      fluidRow(
        column(10,
          checkboxGroupInput(
            "prism_times",
            "Select 2-4 time points to stack:",
            choices  = setNames(0:MAX_TIME, paste0("T", 0:MAX_TIME)),
            selected = c(0, 7, 14),
            inline   = TRUE
          )
        )
      ),
      withSpinner(
        plotOutput("plot_prism", height = "500px"),
        color = "#CC0000", type = 4
      )
    ),

    tabPanel(
      title = "Timeline",
      value = "timeline",
      br(),
      fluidRow(
        column(4,
          selectInput(
            "timeline_type",
            "Timeline Type:",
            choices = c(
              "Activity Timeline"  = "activity",
              "Proximity Timeline" = "proximity"
            ),
            selected = "activity"
          )
        )
      ),
      tags$p(
        uiOutput("timeline_description"),
        style = "color: #666; font-size: 13px;"
      ),
      withSpinner(
        plotOutput("plot_timeline", height = "480px"),
        color = "#CC0000", type = 4
      )
    )
  )
)

tab_animation <- tagList(
  fluidRow(
    box(
      title       = "D3 Network Animation",
      width       = 12,
      status      = "primary",
      solidHeader = TRUE,
      tags$p(
        style = "color: #555; font-size: 13px;",
        "Interactive animation showing how friendship nominations evolve across the semester. ",
        "Use the ", tags$strong("Animation Settings"), " in the sidebar to customize appearance. ",
        "Press Play in the widget controls to watch the network evolve."
      ),
      tags$div(
        style = "display: flex; justify-content: space-between; align-items: flex-start;",
        tags$div(
          style = "flex: 1;",
          withSpinner(
            uiOutput("d3_animation", inline = FALSE),
            color = "#CC0000", type = 4
          )
        ),
        downloadButton(
          "download_animation",
          label = "Download as HTML",
          class = "btn-sm btn-default"
        )
      )
    )
  )
)

