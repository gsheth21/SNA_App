create_header <- function() {
  dashboardHeader(
    title      = tags$span(
      style = "color: #ffffff; font-weight: bold; font-size: 15px; letter-spacing: 0.5px;",
      icon("clock"), " Dynamic Networks"
    ),
    titleWidth = 300,

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
          class    = "nav-link active",
          `data-tab` = "stats",
          icon("chart-line"), " Statistics"
        ),
        tags$a(
          class    = "nav-link",
          `data-tab` = "snapshots",
          icon("camera"), " Snapshots"
        ),
        tags$a(
          class    = "nav-link",
          `data-tab` = "multitime",
          icon("layer-group"), " Multi-Time"
        ),
        tags$a(
          class    = "nav-link",
          `data-tab` = "animation",
          icon("film"), " Animation"
        ),        tags$a(
          class    = "nav-link",
          `data-tab` = "dataset_info",
          icon("database"), " Dataset Info"
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
              href = Sys.getenv("EGOMODE"),
              icon("user"), "Ego Networks"
            ),
            tags$a(
              href  = Sys.getenv("DYNAMICMODE"),
              class = "current-module",
              icon("play-circle"), "Dynamic Nets"
            )
          )
        )
      )
    )
  )
}
