create_sidebar <- function() {
  dashboardSidebar(
    width = 300,

    # App title block
    tags$div(
      style = "padding: 12px 15px 8px;",
      tags$h3(
        style = "color: #ffffff; margin: 0 0 3px 0; font-weight: bold;",
        "Dynamic Networks"
      ),
      tags$small(
        style = "color: #aaa;",
        "Newcomb Fraternity Study, 1956"
      )
    ),

    tags$hr(style = "border-color: rgba(255,255,255,0.15); margin: 4px 0;"),

    # ── SECTION 1: Dataset Info ────────────────────────────────────────────────
    tags$button(
      class   = "sidebar-section-toggle",
      onclick = "toggleSidebarSection(this)",
      tags$span("📊 Dataset Info"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(
      class = "sidebar-section-body", style = "display: none;",
      tags$div(
        style = "padding: 8px 15px 12px;",
        tags$ul(
          style = "padding-left: 18px; color: #ccc; font-size: 13px; margin: 0; line-height: 1.8;",
          tags$li("17 fraternity members"),
          tags$li(paste(N_TIME_POINTS, "weekly time points")),
          tags$li("Directed · Unweighted"),
          tags$li("Top-3 friendship nominations"),
          tags$li("University of Michigan, 1956")
        )
      )
    ),

    # ── SECTION 2: Time Controls ───────────────────────────────────────────────
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("⏱ Time Controls"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(
      class = "sidebar-section-body",
      tags$div(
        style = "padding: 8px 15px 4px;",

        checkboxInput(
          "use_window",
          "Use time window instead of single point",
          value = FALSE
        ),

        # Single time point slider (1-based display)
        conditionalPanel(
          condition = "!input.use_window",
          sliderInput(
            "time_point",
            "Time Point:",
            min   = 1,
            max   = N_TIME_POINTS,
            value = 1,
            step  = 1,
            ticks = TRUE
          )
        ),

        # Time window range slider (0-based to match networkDynamic)
        conditionalPanel(
          condition = "input.use_window",
          sliderInput(
            "time_window",
            "Time Window (onset → terminus):",
            min   = 0,
            max   = MAX_TIME,
            value = c(0, floor(MAX_TIME / 2)),
            step  = 1,
            ticks = TRUE
          )
        )
      )
    ),

    # ── SECTION 3: Display Settings ───────────────────────────────────────────
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🎨 Display Settings"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(
      class = "sidebar-section-body",
      tags$div(
        style = "padding: 8px 15px 4px;",

        checkboxInput("show_labels", "Show Node Labels", value = TRUE),
        checkboxInput("show_arrows", "Show Arrows",      value = TRUE),

        selectInput(
          "node_color",
          "Node Color:",
          choices = c(
            "Red (NC State)" = "#CC0000",
            "Steel Blue"     = "#4682B4",
            "Forest Green"   = "#228B22",
            "Orange"         = "#FF8C00",
            "Purple"         = "#6A3D9A",
            "Black"          = "#000000"
          ),
          selected = "#CC0000"
        ),

        selectInput(
          "edge_color",
          "Edge Color:",
          choices = c(
            "Dark Gray"  = "#555555",
            "Black"      = "#000000",
            "Red"        = "#CC0000",
            "Steel Blue" = "#4682B4"
          ),
          selected = "#555555"
        ),

        sliderInput("node_size",  "Node Size:",  min = 0.5, max = 3.0, value = 1.2, step = 0.1),
        sliderInput("label_size", "Label Size:", min = 0.4, max = 1.5, value = 0.7, step = 0.1)
      )
    ),

    # ── SECTION 4: Animation Settings ─────────────────────────────────────────
    tags$button(
      class   = "sidebar-section-toggle",
      onclick = "toggleSidebarSection(this)",
      tags$span("🎬 Animation Settings"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(
      class = "sidebar-section-body", style = "display: none;",
      tags$div(
        style = "padding: 8px 15px 4px;",
        tags$small(
          style = "color: #aaa; display: block; margin-bottom: 10px;",
          "These settings apply to the D3 animation tab only."
        ),

        selectInput(
          "anim_bg",
          "Background:",
          choices  = c("Black" = "black", "White" = "white", "Dark Gray" = "#333333"),
          selected = "white"
        ),

        selectInput(
          "anim_node_color",
          "Node Color:",
          choices  = c(
            "Firebrick"      = "firebrick1",
            "Red (NC State)" = "#CC0000",
            "Steel Blue"     = "steelblue",
            "White"          = "white"
          ),
          selected = "firebrick1"
        ),

        selectInput(
          "anim_edge_color",
          "Edge Color:",
          choices  = c(
            "Ivory"      = "ivory",
            "White"      = "white",
            "Light Gray" = "#cccccc",
            "Steel Blue" = "steelblue",
            "Black"      = "black"
          ),
          selected = "black"
        ),

        checkboxInput("anim_labels", "Show Labels",  value = TRUE),
        checkboxInput("anim_arrows", "Show Arrows",  value = FALSE)
      )
    )
  )
}
