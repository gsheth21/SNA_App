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
        ),

        # ── Module Switcher ──────────────────────────────────
        tags$div(class = "module-divider"),
        tags$div(
          class = "module-switcher",
          tags$a(
            class = "module-btn",
            href  = "#",
            icon("th-large"), " Apps ▾"
          ),
          tags$div(
            class = "module-dropdown",
            tags$a(
              href = Sys.getenv("ONEMODE"),
              icon("circle"), "One-Mode Networks"
            ),
            tags$a(
              href  = Sys.getenv("TWOMODE"),
              class = "current-module",
              icon("th"), "Two-Mode Networks"
            ),
            tags$a(
              href = Sys.getenv("TEXTMODE"),
              icon("font"), "Text Networks"
            ),
            tags$a(
              href = Sys.getenv("EGOMODE"),
              icon("user"), "Ego Networks"
            ),
            tags$a(
              href = Sys.getenv("DYNAMICMODE"),
              icon("play-circle"), "Dynamic Nets"
            )
          )
        )
      )
    )
  )
}
