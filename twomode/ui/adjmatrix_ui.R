adjmatrix_ui <- tagList(

  # ── Intro ──────────────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "13.2 Two Mode Networks From Adjacency Matrices",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("A two-mode network can also be stored as an ", tags$strong("affiliation matrix"),
        " (also called a biadjacency matrix). Rows represent one mode and columns represent
        the other. Cell values of 1 indicate a tie; 0 indicates no tie — identical logic to
        a regular adjacency matrix."),
      p("In this dataset, rows are artists and columns are songs.")
    )
  ),

  # ── Matrix Table ───────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "artist_track_adj (first 10 artists × 10 songs shown)",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p(tags$small("Rows = artists, columns = songs. Values: 1 = appeared on that song, 0 = did not.
                    Scroll right to see more songs."),
        style = "color: #888; margin-bottom: 10px;"),
      DTOutput("adjmatrix_table")
    )
  ),

  # ── Code + Comparison ──────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "Building the Network Object",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p("Use ", tags$code("graph_from_biadjacency_matrix()"),
        " instead of the regular ", tags$code("graph_from_adjacency_matrix()"), "."),
      p("This function automatically generates the ", tags$code("type"),
        " vertex attribute and flags the object as bipartite — no extra step needed."),
      tags$pre(
        class = "r-code",
        style = "background:#f5f5f5; padding:10px; border-radius:4px; font-size:12px;",
        "a_t_g2 <- graph_from_biadjacency_matrix(artist_track_adj)

unique(V(a_t_g2)$type)  # TRUE and FALSE

a_t_g2  # Shows UN-B (undirected bipartite)"
      )
    ),
    box(
      title       = "Both Methods, Same Result",
      width       = 6,
      solidHeader = TRUE,
      status      = "success",
      p("Both approaches — edgelist and affiliation matrix — produce an identical bipartite
        graph object. The key difference is the source format, not the resulting network."),
      p("The ", tags$code("a_t_g2"), " object built from the affiliation matrix is the ",
        tags$strong("primary graph"), " used throughout all remaining chapters."),
      hr(),
      uiOutput("adjmatrix_network_summary")
    )
  )
)
