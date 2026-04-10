source(here::here("twomode", "ui", "ui_header.R"))
source(here::here("twomode", "ui", "ui_sidebar.R"))

# Chapter UIs
source(here::here("twomode", "ui", "edgelist_ui.R"))
source(here::here("twomode", "ui", "adjmatrix_ui.R"))
source(here::here("twomode", "ui", "viz_ui.R"))
source(here::here("twomode", "ui", "degree_ui.R"))
source(here::here("twomode", "ui", "betweenness_ui.R"))
source(here::here("twomode", "ui", "projection_ui.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))

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
