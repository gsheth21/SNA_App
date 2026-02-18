create_header <- function() {
  dashboardHeader(
    title = "One-Mode Network Analysis",
    titleWidth = 300,
    
    # Horizontal Navigation Bar
    tags$li(
      class = "dropdown",
      style = "padding: 0; margin: 0; height: 50px;",
      tags$div(
        id = "horizontal-nav",
        style = "display: flex; align-items: center; height: 50px; margin-left: 20px;",
        tags$a(href = "#", class = "nav-link", `data-tab` = "overview", icon("home"), "Overview"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "networks", icon("project-diagram"), "Networks"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "visualization", icon("eye"), "Visualization"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "connectivity", icon("link"), "Connectivity"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "centrality", icon("star"), "Centrality"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "communities", icon("users"), "Communities"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "assortativity", icon("bullseye"), "Assortativity"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "roles", icon("theater-masks"), "Roles"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "simulation", icon("dice"), "Simulation"),
        tags$a(href = "#", class = "nav-link", `data-tab` = "about", icon("info-circle"), "About")
      )
    ),
    
    # Help button
    tags$li(
      class = "dropdown",
      tags$a(
        href = "#",
        icon("question-circle"),
        "Help",
        onclick = "Shiny.setInputValue('show_help', Math.random());"
      )
    )
  )
}