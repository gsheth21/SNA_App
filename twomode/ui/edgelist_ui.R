edgelist_ui <- tagList(

  # ── Intro ──────────────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "13.1 Two Mode Networks From Edgelists",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("In two-mode networks, an edgelist is structured so that one mode appears exclusively
        in the first column and the second mode exclusively in the second column. Rows still
        represent connections, but these columns must be mutually exclusive — artists only in
        one column, songs only in the other."),
      p(tags$small("Dataset: Grime artists and the tracks they appeared on in 2008."),
        style = "color: #888;")
    )
  ),

  # ── Edgelist Table ─────────────────────────────────────────────────────────
  fluidRow(
    box(
      title       = "artist_track_edge",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p(tags$small("Each row = one artist–track connection. Artists appear only in the first column;
                    songs only in the second."),
        style = "color: #888; margin-bottom: 10px;"),
      DTOutput("edgelist_table")
    )
  ),

  # ── Code walkthrough + Network Summary ─────────────────────────────────────
  fluidRow(
    box(
      title       = "Building the Network Object",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(tags$strong("Step 1:"), " Use ", tags$code("graph_from_data_frame()"),
        " with ", tags$code("directed = FALSE"), "."),
      p(tags$strong("Step 2:"), " Apply ", tags$code("bipartite_mapping()"),
        " — this scans the network to confirm the two-mode structure and returns a logical
        vector of node types."),
      p(tags$strong("Step 3:"), " Assign the result as the ", tags$code("type"),
        " vertex attribute. ", tags$code("FALSE"), " = Artist, ", tags$code("TRUE"), " = Song."),
      tags$pre(
        class = "r-code",
        style = "background:#f5f5f5; padding:10px; border-radius:4px; font-size:12px;",
        "a_t_g <- graph_from_data_frame(artist_track_edge, directed = F)

V(a_t_g)$type <- bipartite_mapping(a_t_g)$type

unique(V(a_t_g)$type)  # TRUE and FALSE"
      )
    ),
    box(
      title       = "Network Summary (from edgelist)",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      uiOutput("edgelist_network_summary")
    )
  )
)
