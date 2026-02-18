source(here::here("ui", "ui_header.R"))
source(here::here("ui", "ui_sidebar.R"))

# Source all chapter UIs
source(here::here("ui", "overview_ui.R"))
source(here::here("ui", "networks_ui.R"))
source(here::here("ui", "visualization_ui.R"))
source(here::here("ui", "connectivity_ui.R"))
source(here::here("ui", "centrality_ui.R"))
source(here::here("ui", "communities_ui.R"))
source(here::here("ui", "assortativity_ui.R"))
source(here::here("ui", "roles_ui.R"))
source(here::here("ui", "simulation_ui.R"))

source(here::here("helpers", "ui_styles.R"))
source(here::here("helpers", "ui_helpers.R"))

# Main UI definition
ui <- dashboardPage(
  skin = "red",  # NC State theme
  
  # Header
  header = create_header(),
  
  # Sidebar
  sidebar = create_sidebar(),

  # Main Body
  body = dashboardBody(
    useShinyjs(),
    
    # Custom CSS and JavaScript
    tags$head(
      get_custom_css(),
      get_custom_javascript()
    ),

    uiOutput("tab_content")
  )
)