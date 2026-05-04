create_header <- function() {
  dashboardHeader(
    tags$li(
      class = "dropdown",
      style = "padding: 0; margin: 0; height: 50px;",
      tags$div(
        id = "horizontal-nav",
        actionButton(
          "sidebar-toggle-button",
          icon  = icon("bars"),
          label = NULL
        ),
        tags$a(
          class      = "nav-link active",
          `data-tab` = "overview",
          icon("home"),
          "Overview"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "textprep",
          icon("align-left"),
          "Text Prep"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "pairs",
          icon("grip-lines"),
          "Co-occurrence"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "network",
          icon("project-diagram"),
          "Network"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "centrality",
          icon("star"),
          "Centrality"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "viz",
          icon("eye"),
          "Visualization"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "clusters",
          icon("object-group"),
          "Clusters"
        ),
        tags$a(
          class      = "nav-link",
          `data-tab` = "about",
          icon("info-circle"),
          "About"
        )
      )
    )
  )
}
