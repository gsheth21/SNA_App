create_sidebar <- function() {
  dashboardSidebar(
    width = 300,

    h3("Text Network Analysis", id = "logo"),
    hr(),

    # ============================================================
    # Dataset Info (static)
    # ============================================================
    h4("📊 Dataset", id = "heading"),
    tags$div(
      style = "font-size: 14px;",
      p(
        style = "padding-left: 15px; padding-right: 15px; margin: 0;",
        tags$strong("Declaration of Independence (1776)"),
        br(),
        tags$span(style = "color: #aaa;", "14 sentences · ~400 tokens")
      )
    ),

    hr(),

    # ============================================================
    # SECTION 1: Stopwords
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🚫 Extra Stopwords"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px; padding-right: 15px;",
        p(style = "font-size: 12px; color: #aaa; margin-bottom: 4px;",
          "Comma or newline separated words to remove (in addition to standard stopwords)."),
        textAreaInput(
          "extra_stops",
          label   = NULL,
          value   = paste(default_custom_stops, collapse = ", "),
          rows    = 3,
          resize  = "none",
          width   = "100%"
        )
      )
    ),

    # ============================================================
    # SECTION 2: Top N Pairs
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🔢 Top N Pairs"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px; padding-right: 15px;",
        sliderInput(
          "n_pairs",
          label = NULL,
          min   = 10,
          max   = 100,
          value = 50,
          step  = 5
        )
      )
    ),

    # ============================================================
    # SECTION 3: Layout Algorithm
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("📐 Layout Algorithm"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px;",
        selectInput(
          "layout",
          NULL,
          choices = c(
            "Fruchterman-Reingold" = "fr",
            "Kamada-Kawai"         = "kk",
            "Stress"               = "stress",
            "Circle"               = "circle"
          ),
          selected = "fr"
        )
      )
    ),

    # ============================================================
    # SECTION 4: Node Appearance
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🟡 Node Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px; padding-right: 15px;",
        sliderInput("node_size",  "Node Size",  min = 1, max = 10, value = 4, step = 0.5),
        sliderInput("label_size", "Label Size", min = 1, max = 8,  value = 3, step = 0.5)
      )
    ),

    # ============================================================
    # SECTION 5: Edge Appearance
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("➡ Edge Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px; padding-right: 15px;",
        sliderInput("edge_alpha", "Edge Opacity", min = 0.05, max = 1, value = 0.25, step = 0.05)
      )
    )
  )
}
