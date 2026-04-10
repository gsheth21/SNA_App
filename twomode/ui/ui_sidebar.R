create_sidebar <- function() {
  dashboardSidebar(
    width = 300,

    h3("Two-Mode Network Analysis", id = "logo"),
    hr(),

    # ============================================================
    # Network Info (static summary from global.R)
    # ============================================================
    h4("📊 Network Info", id = "heading"),
    tags$div(
      style = "padding-left: 15px; font-size: 13px;",
      tags$ul(
        style = "padding-left: 15px; margin: 0;",
        tags$li(HTML(paste0("<strong>Artists:</strong> ", n_artists))),
        tags$li(HTML(paste0("<strong>Songs:</strong>   ", n_songs))),
        tags$li(HTML(paste0("<strong>Edges:</strong>   ", n_edges)))
      )
    ),

    hr(),

    # ============================================================
    # SECTION 1: Graph Layers
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🔲 Graph Layers"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px;",
        checkboxGroupInput(
          "layer_selection",
          NULL,
          choices  = c("Edges" = "edges", "Labels" = "labels"),
          selected = c("edges")
        )
      )
    ),

    # ============================================================
    # SECTION 2: Layout Algorithm
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
            "Davidson-Harel"       = "dh",
            "Fruchterman-Reingold" = "fr",
            "Kamada-Kawai"         = "kk",
            "Stress"               = "stress",
            "Bipartite"            = "bipartite"
          ),
          selected = "dh"
        )
      )
    ),

    # ============================================================
    # SECTION 3: Node Appearance
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("🎨 Node Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px;",

        strong("Artist Nodes", style = "font-size: 12px; color: #aaa;"),
        tags$br(), tags$br(),

        selectInput(
          "artist_color",
          "Artist Color:",
          choices = c(
            "Steel Blue"   = "steelblue1",
            "Blue"         = "#1f78b4",
            "NC State Red" = "#CC0000",
            "Black"        = "#000000",
            "Green"        = "#33a02c",
            "Orange"       = "#ff7f00"
          ),
          selected = "steelblue1"
        ),

        tags$br(),
        strong("Song Nodes", style = "font-size: 12px; color: #aaa;"),
        tags$br(), tags$br(),

        selectInput(
          "song_color",
          "Song Color:",
          choices = c(
            "Maroon"       = "maroon",
            "NC State Red" = "#CC0000",
            "Purple"       = "#6a3d9a",
            "Green"        = "#33a02c",
            "Orange"       = "#ff7f00",
            "Black"        = "#000000"
          ),
          selected = "maroon"
        ),

        tags$br(),
        sliderInput("node_size", "Node Size:", min = 0.5, max = 5, value = 1, step = 0.5)
      )
    ),

    # ============================================================
    # SECTION 4: Edge Appearance
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("➡️ Edge Appearance"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px;",
        sliderInput("edge_opacity", "Edge Opacity:", min = 0.05, max = 0.5, value = 0.2, step = 0.05)
      )
    ),

    # ============================================================
    # SECTION 5: Analysis Settings (degree threshold)
    # ============================================================
    tags$button(
      class   = "sidebar-section-toggle open",
      onclick = "toggleSidebarSection(this)",
      tags$span("⚙️ Analysis Settings"),
      tags$span(class = "toggle-arrow", "▼")
    ),
    tags$div(class = "sidebar-section-body",
      div(style = "padding-left: 15px;",
        p(tags$small("Threshold used for above/below average degree grouping in plots:"),
          style = "color: #aaa; margin-bottom: 8px;"),
        numericInput("artist_threshold", "Artist Degree Threshold:",
                     value = 3, min = 1, max = 200, step = 1),
        numericInput("song_threshold",   "Song Degree Threshold:",
                     value = 3, min = 1, max = 400, step = 1)
      )
    )
  )
}
