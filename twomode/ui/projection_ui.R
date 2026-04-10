projection_ui <- tagList(

  # ── Concept ────────────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "13.6 Projecting One Mode Networks",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("One of the classic applications of two-mode analysis is to project a one-mode network
        for each set of nodes. This produces two separate networks:"),
      tags$ul(
        tags$li(
          tags$strong("Artist–Artist network (proj1):"),
          " Two artists are tied if they appeared on the same song.
          Ties are weighted by the number of songs they co-appeared on."
        ),
        tags$li(
          tags$strong("Song–Song network (proj2):"),
          " Two songs are tied if they share at least one artist.
          Ties are weighted by the number of artists they share."
        )
      ),
      p("This conversion is grounded in Breiger's (1974) concept of the ",
        tags$strong("duality of persons and groups"),
        " — affiliations simultaneously define both person-level and group-level social structures."),
      div(
        style = "background:#fff3cd; border-left:4px solid #ffc107; padding:10px; border-radius:4px; margin-top:10px;",
        tags$strong("⚠️ Caution:"),
        p("Degree and betweenness measures from the projected one-mode networks will NOT equal
          those from the original two-mode network. The two-mode structure is lost in projection.
          See Everett & Borgatti (2013) for detailed discussion.", style = "margin:0;")
      )
    )
  ),

  # ── Projection Summary ─────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "Projection Object Summary",
      width       = 12,
      solidHeader = TRUE,
      status      = "info",
      uiOutput("projection_summary")
    )
  ),

  # ── Side-by-side plots ─────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "Artist–Artist Network (proj1)",
      width       = 6,
      solidHeader = TRUE,
      status      = "primary",
      p(tags$small("Artists connected by songs they co-appeared on. Edge weight = number of
                    shared songs. Layout: Fruchterman-Reingold (fr), seed = 123."),
        style = "color: #888; margin-bottom: 10px;"),
      withSpinner(plotOutput("proj1_plot", height = "500px"), color = "#CC0000", type = 4)
    ),
    box(
      title       = "Song–Song Network (proj2)",
      width       = 6,
      solidHeader = TRUE,
      status      = "primary",
      p(tags$small("Songs connected by artists they share. Edge weight = number of shared artists.
                    Layout: Fruchterman-Reingold (fr), seed = 123."),
        style = "color: #888; margin-bottom: 10px;"),
      withSpinner(plotOutput("proj2_plot", height = "500px"), color = "#CC0000", type = 4)
    )
  )
)
