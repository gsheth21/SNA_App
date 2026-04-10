source(here::here("twomode", "server", "edgelist_server.R"))
source(here::here("twomode", "server", "adjmatrix_server.R"))
source(here::here("twomode", "server", "viz_server.R"))
source(here::here("twomode", "server", "centrality_server.R"))
source(here::here("twomode", "server", "projection_server.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))
source(here::here("shared", "helpers", "network_helpers.R"))
source(here::here("shared", "helpers", "plot_helpers.R"))
source(here::here("shared", "helpers", "ggraph_helpers.R"))

server <- function(input, output, session) {

  # ── Current tab tracking ────────────────────────────────────────────────────
  current_tab <- reactiveVal("edgelist")

  observeEvent(input$current_tab, {
    req(input$current_tab)
    current_tab(input$current_tab)
  }, ignoreNULL = TRUE, ignoreInit = FALSE)

  # ── Reactive values ─────────────────────────────────────────────────────────
  # The graph is fixed (loaded in global.R); rv holds it for consistent access
  rv <- reactiveValues(
    graph = a_t_g2
  )

  # ── Tab routing ─────────────────────────────────────────────────────────────
  output$tab_content <- renderUI({
    tab <- current_tab()

    switch(tab,
      "edgelist"    = tags$div(id = "tab-edgelist",    class = "tab-inner", edgelist_ui),
      "adjmatrix"   = tags$div(id = "tab-adjmatrix",   class = "tab-inner", adjmatrix_ui),
      "viz"         = tags$div(id = "tab-viz",         class = "tab-inner", viz_ui),
      "degree"      = tags$div(id = "tab-degree",      class = "tab-inner", degree_ui),
      "betweenness" = tags$div(id = "tab-betweenness", class = "tab-inner", betweenness_ui),
      "projection"  = tags$div(id = "tab-projection",  class = "tab-inner", projection_ui),
      "about"       = tags$div(
        id = "tab-about", class = "tab-inner",
        fluidRow(
          box(
            title       = "About Two-Mode Network Analysis",
            width       = 12,
            solidHeader = TRUE,
            status      = "primary",
            h4("Two-Mode Network Analysis — Chapter 13"),
            p("This app implements Chapter 13 of the Social Network Analysis textbook.
              It covers two-mode (bipartite) networks from data loading through visualization,
              centrality analysis, and one-mode projection."),
            hr(),
            h5("Data Source"),
            p("The Grime artist–track dataset captures which artists appeared on which songs
              in 2008. Each edge links an artist to a track."),
            tags$ul(
              tags$li(HTML(paste0("<strong>Artists:</strong> ", n_artists))),
              tags$li(HTML(paste0("<strong>Songs:</strong> ", n_songs))),
              tags$li(HTML(paste0("<strong>Edges:</strong> ", n_edges)))
            ),
            hr(),
            h5("Key Concepts"),
            tags$ul(
              tags$li(tags$strong("Bipartite:"),
                      " Ties exist only between modes, never within a mode."),
              tags$li(tags$strong("Degree centrality:"),
                      " For artists = expansiveness; for songs = popularity."),
              tags$li(tags$strong("Betweenness:"),
                      " Cross-mode brokerage — how often a node bridges otherwise separate clusters."),
              tags$li(tags$strong("Projection:"),
                      " Convert to one-mode artist–artist or song–song network via shared affiliations.")
            ),
            hr(),
            h5("References"),
            tags$ul(
              tags$li("Borgatti, S. P., & Everett, M. G. (1997). Network analysis of 2-mode data.
                       Social Networks, 19(3), 243–269."),
              tags$li("Breiger, R. L. (1974). The duality of persons and groups.
                       Social Forces, 53(2), 181–190."),
              tags$li("Everett, M. G., & Borgatti, S. P. (2013). The dual-projection approach
                       for two-mode networks. Social Networks, 35(2), 204–210.")
            )
          )
        )
      ),
      # Default fallback
      tags$div(id = "tab-edgelist", class = "tab-inner", edgelist_ui)
    )
  })

  # ── Call chapter servers ────────────────────────────────────────────────────
  edgelist_server(input, output, session, rv)
  adjmatrix_server(input, output, session, rv)
  viz_server(input, output, session, rv)
  centrality_server(input, output, session, rv)
  projection_server(input, output, session, rv)
}
