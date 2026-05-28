source(here::here("textmode", "ui", "ui_header.R"))
source(here::here("textmode", "ui", "ui_sidebar.R"))

# Chapter UIs
source(here::here("textmode", "ui", "overview_ui.R"))
source(here::here("textmode", "ui", "textprep_ui.R"))
source(here::here("textmode", "ui", "pairs_ui.R"))
source(here::here("textmode", "ui", "network_ui.R"))
source(here::here("textmode", "ui", "centrality_ui.R"))
source(here::here("textmode", "ui", "viz_ui.R"))
source(here::here("textmode", "ui", "clusters_ui.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))

ui <- dashboardPage(
  skin = "red",

  header  = create_header(),
  sidebar = create_sidebar(),

  body = dashboardBody(
    useShinyjs(),
    tags$head(
      tags$title("Text Network Analysis"),
      includeCSS(here::here("www", "styles.css")),
      includeScript(here::here("www", "script.js"))
    ),

    # Visually hidden h1 for screen readers (page-has-heading-one)
    tags$h1("Text Network Analysis", class = "sr-only"),

    uiOutput("tab_content")
  )
)
