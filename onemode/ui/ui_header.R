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
          `data-tab` = "overview",
          icon("home"),
          "Overview"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "networks",
          icon("project-diagram"),
          "Networks"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "connectivity",
          icon("link"),
          "Connectivity"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "centrality",
          icon("star"),
          "Centrality"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "communities",
          icon("users"),
          "Communities"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "assortativity",
          icon("bullseye"),
          "Assortativity"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "roles",
          icon("theater-masks"),
          "Roles"
        ),
        tags$a(
          class = "nav-link",
          `data-tab` = "simulation",
          icon("dice"),
          "Simulation"
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
              href  = Sys.getenv("ONEMODE"),
              class = "current-module",
              icon("circle"), "One-Mode Networks"
            ),
            tags$a(
              href = Sys.getenv("TWOMODE"),
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