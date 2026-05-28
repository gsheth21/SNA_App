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
          `data-tab` = "dataset_info",
          icon("database"),
          "Dataset Info"
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
              href = Sys.getenv("ONEMODE"),
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
              href  = Sys.getenv("EGOMODE"),
              class = "current-module",
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
