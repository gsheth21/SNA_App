source(here::here("onemode", "ui", "ui_header.R"))
source(here::here("onemode", "ui", "ui_sidebar.R"))

# Source all chapter UIs
source(here::here("onemode", "ui", "overview_ui.R"))
source(here::here("onemode", "ui", "networks_ui.R"))
source(here::here("onemode", "ui", "connectivity_ui.R"))
source(here::here("onemode", "ui", "centrality_ui.R"))
source(here::here("onemode", "ui", "communities_ui.R"))
source(here::here("onemode", "ui", "assortativity_ui.R"))
source(here::here("onemode", "ui", "roles_ui.R"))
source(here::here("onemode", "ui", "simulation_ui.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))

# Main UI definition
ui <- dashboardPage(
  skin = "red", 
  
  # Header
  header = create_header(),
  
  # Sidebar
  sidebar = create_sidebar(),

  # Main Body
  body = dashboardBody(
    useShinyjs(),
    
    # Custom CSS and JavaScript
    tags$head(
      includeCSS(here::here("www", "styles.css")),
      includeScript(here::here("www", "script.js"))
      # tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      # tags$script(src = "script.js")
    ),

    uiOutput("tab_content")
  )
)