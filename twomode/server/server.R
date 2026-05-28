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
      "dataset_info" = tags$div(
        id = "tab-dataset_info", class = "tab-inner",
        fluidRow(
          box(
            title       = tagList(icon("database"), " Grime Music Artist-Track Network"),
            width       = 12,
            solidHeader = TRUE,
            status      = "primary",
            h4("Grime Music Bipartite Network (2008)", style = "margin-top: 0; color: #CC0000;"),
            hr(),
            h5("Background"),
            p("A two-mode (bipartite) network representing the affiliation between artists and songs in the 2008
              UK grime music corpus. Grime is a genre of electronic music that emerged from London in the early
              2000s, characterized by dense collaboration networks among artists. Each edge links an artist to
              a track on which they appeared. This structure is ideal for demonstrating two-mode network analysis:
              degree and betweenness centrality differ meaningfully across modes, and one-mode projections reveal
              hidden artist\u2013artist or song\u2013song co-affiliation structures."),
            hr(),
            h5("Network Structure"),
            tags$table(
              class = "table table-condensed",
              style = "font-size: 13px; margin-bottom: 8px; width: auto;",
              tags$tbody(
                tags$tr(tags$td(strong("Type:"),     style = "padding-right: 16px;"), tags$td("Two-mode (bipartite) network")),
                tags$tr(tags$td(strong("Directed:")), tags$td("No")),
                tags$tr(tags$td(strong("Weighted:")), tags$td("No (binary)")),
                tags$tr(tags$td(strong("Domain:")),   tags$td("Cultural Sociology / Music Studies / Bipartite Networks"))
              )
            ),
            tags$table(
              class = "table table-condensed table-hover",
              style = "font-size: 13px;",
              tags$thead(tags$tr(
                tags$th("R Object"), tags$th("Dimension", style = "text-align: center;"), tags$th("Description")
              )),
              tags$tbody(
                tags$tr(tags$td(tags$code("artist_track_adj")),  tags$td("372 \u00d7 391", style = "text-align: center;"), tags$td("Adjacency matrix (artists \u00d7 songs)")),
                tags$tr(tags$td(tags$code("artist_track_edge")), tags$td("1,143 rows",     style = "text-align: center;"), tags$td("Edgelist (artist\u2013song pairs)"))
              )
            ),
            hr(),
            h5("Node Modes"),
            tags$ul(
              tags$li(strong("Mode 1 \u2014 Artists: "), HTML(paste0("<strong>", n_artists, "</strong> nodes (e.g., Wiley, Kano, Scorcher)"))),
              tags$li(strong("Mode 2 \u2014 Songs: "),   HTML(paste0("<strong>", n_songs, "</strong> nodes")))
            ),
            hr(),
            h5("References"),
            tags$ul(
              tags$li("Borgatti, S. P., & Everett, M. G. (1997). Network analysis of 2-mode data. Social Networks, 19(3), 243\u2013269."),
              tags$li("Breiger, R. L. (1974). The duality of persons and groups. Social Forces, 53(2), 181\u2013190."),
              tags$li("Everett, M. G., & Borgatti, S. P. (2013). The dual-projection approach for two-mode networks. Social Networks, 35(2), 204\u2013210.")
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
