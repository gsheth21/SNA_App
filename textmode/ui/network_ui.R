network_ui <- tagList(

  fluidRow(
    box(
      title       = "Step 7 · From Pairs to Graph Object",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p(code("graph_from_data_frame()"), " converts the filtered pairs table into an igraph
        object. This is the moment the data changes form — from a table of word pairs
        to a network that can be summarized and visualized."),
      tags$pre(
        class = "r-code",
        style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'word_graph <- graph_from_data_frame(pairs_filtered, directed = FALSE)'
      )
    )
  ),

  # Network summary stats
  fluidRow(
    box(
      title       = "📊 Network Properties",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      uiOutput("network_properties")
    ),
    box(
      title       = "ℹ️ igraph Object Summary",
      width       = 6,
      solidHeader = TRUE,
      status      = "info",
      p(style = "font-size: 12px; color: #888;",
        "The printed igraph object shows the number of nodes, edges,
        graph type, and the first few edges."),
      withSpinner(verbatimTextOutput("graph_summary"), color = "#CC0000", type = 4)
    )
  ),

  # Degree distribution
  fluidRow(
    box(
      title       = "📈 Degree Distribution",
      width       = 12,
      solidHeader = TRUE,
      status      = "info",
      p("How many words are connected to exactly k other words?
        A heavy right tail (few highly-connected 'hub' words) is common in text networks."),
      withSpinner(plotlyOutput("degree_dist_plot", height = "350px"), color = "#CC0000", type = 4)
    )
  )
)
