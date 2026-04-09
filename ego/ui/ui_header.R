create_header <- function() {
  dashboardHeader(
    tags$li(
      class = "dropdown",
      style = "padding: 0; margin: 0; height: 50px;",
      tags$div(
        id = "horizontal-nav",
        actionButton(
          "sidebar-toggle-button",
          icon = icon("bars"),
          label = NULL
        ),
        tags$a(
          class = "nav-link active",
          `data-tab` = "setup",
          icon("wrench"),
          "Setup"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "analysis",
          icon("chart-line"),
          "Analysis"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "about",
          icon("info-circle"),
          "About"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "help",
          icon("question-circle"),
          "Help"
        )
      )
    )
  )
}
