betweenness_ui <- tagList(

  # ── Concept ────────────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "13.5 Betweenness Centrality in Two Mode Networks",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("Betweenness centrality reflects how often a node lies on the shortest path between
        other pairs of nodes. In two-mode networks, paths must cross modes —
        person → group → person — because direct within-mode ties cannot exist."),
      tags$ul(
        tags$li(
          tags$strong("Artists:"),
          " High betweenness = bridges across otherwise disconnected parts of the
          track–artist structure. These artists connect separate clusters in the network."
        ),
        tags$li(
          tags$strong("Songs:"),
          " High betweenness = 'meeting points' or shared contexts that link unconnected
          clusters of artists. Songs are not agentic but serve as structural connectors."
        )
      ),
      p(tags$small("The measure is calculated identically to one-mode betweenness, but
                    interpretation emphasises cross-mode brokerage rather than direct influence
                    among nodes of the same type."),
        style = "color: #888;")
    )
  ),

  # ── Artist Betweenness ─────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "Artist Betweenness Centrality",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(tags$small("Summary statistics across all ", n_artists, " artists."),
        style = "color: #888; margin-bottom: 8px;"),
      DTOutput("artist_between_summary"),
      br(),
      uiOutput("artist_between_callout")
    ),

    # ── Song Betweenness ──────────────────────────────────────────────────────
    box(
      title       = "Song Betweenness Centrality",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(tags$small("Summary statistics across all ", n_songs, " songs."),
        style = "color: #888; margin-bottom: 8px;"),
      DTOutput("song_between_summary"),
      br(),
      uiOutput("song_between_callout")
    )
  )
)
