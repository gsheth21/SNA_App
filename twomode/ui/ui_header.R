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
          class     = "nav-link active",
          `data-tab` = "edgelist",
          icon("list"),
          "Edgelists"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "adjmatrix",
          icon("table"),
          "Adj. Matrix"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "viz",
          icon("eye"),
          "Visualization"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "degree",
          icon("star"),
          "Degree"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "betweenness",
          icon("route"),
          "Betweenness"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "projection",
          icon("project-diagram"),
          "Projections"
        ),
        tags$a(
          class     = "nav-link",
          `data-tab` = "about",
          icon("info-circle"),
          "About"
        )
      )
    )
  )
}
