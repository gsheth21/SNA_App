degree_ui <- tagList(

  # ── Concept ────────────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "13.4 Degree Centrality in Two Mode Networks",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("Degree centrality counts the number of neighbours a node has. The logic is the same
        as in one-mode networks, but interpretation depends on which mode you are examining."),
      tags$ul(
        tags$li(
          tags$strong("Artists:"),
          " Degree = number of songs they appeared on in 2008. Reflects how ",
          tags$em("expansive"), " they are in this two-mode world. Maximum possible = N(Songs) = ",
          tags$strong(n_songs), "."
        ),
        tags$li(
          tags$strong("Songs:"),
          " Degree = number of artists featured on that song. Reflects how ",
          tags$em("popular / collaborative"), " the song is. Maximum possible = N(Artists) = ",
          tags$strong(n_artists), "."
        )
      ),
      p(tags$small("Borgatti & Everett (1997): The maximal degree for each mode equals the N of the opposite mode."),
        style = "color: #888;")
    )
  ),

  # ── Artist Degree ──────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "Artist Degree Centrality",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(tags$small("Summary statistics across all ", n_artists, " artists."),
        style = "color: #888; margin-bottom: 8px;"),
      DTOutput("artist_degree_summary"),
      br(),
      p(tags$small("Network plot: artists colored red (above threshold) or black (below).
                    Songs shown in grey. Adjust 'Artist Degree Threshold' in the sidebar."),
        style = "color: #888; margin-bottom: 8px;"),
      withSpinner(plotOutput("artist_degree_plot", height = "420px"), color = "#CC0000", type = 4)
    ),

    # ── Song Degree ───────────────────────────────────────────────────────────
    box(
      title       = "Song Degree Centrality",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(tags$small("Summary statistics across all ", n_songs, " songs."),
        style = "color: #888; margin-bottom: 8px;"),
      DTOutput("song_degree_summary"),
      br(),
      p(tags$small("Network plot: songs colored red (above threshold) or black (below).
                    Artists shown in grey. Adjust 'Song Degree Threshold' in the sidebar."),
        style = "color: #888; margin-bottom: 8px;"),
      withSpinner(plotOutput("song_degree_plot", height = "420px"), color = "#CC0000", type = 4)
    )
  )
)
