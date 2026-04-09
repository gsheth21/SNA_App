source(here::here("ego", "ui", "ui_header.R"))
source(here::here("ego", "ui", "ui_sidebar.R"))

# Source all chapter UIs
source(here::here("ego", "ui", "setup_ui.R"))
source(here::here("ego", "ui", "analysis_ui.R"))

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
    ),

    uiOutput("tab_content")
  )
)
