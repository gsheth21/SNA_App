centrality_ui <- tagList(

  fluidRow(
    box(
      title       = "Step 8 · Most Connected Words",
      width       = 12,
      solidHeader = TRUE,
      status      = "primary",
      p("Before visualizing, it helps to identify the most central terms numerically.
        Three measures are computed:"),
      tags$ul(
        tags$li(strong("Degree:"),
                " number of distinct words this word co-occurs with (in the filtered graph)"),
        tags$li(strong("Weighted Degree (Strength):"),
                " sum of edge weights — total co-occurrence count across all sentence contexts"),
        tags$li(strong("Betweenness:"),
                " how often this word sits on the shortest path between other word pairs;
                high betweenness words bridge semantic clusters")
      ),
      tags$pre(
        class = "r-code",
        style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'centrality_tbl <- tibble(
  word            = V(word_graph)$name,
  degree          = igraph::degree(word_graph),
  weighted_degree = igraph::strength(word_graph),
  betweenness     = igraph::betweenness(word_graph, directed = FALSE)
) %>%
  arrange(desc(weighted_degree))'
      )
    )
  ),

  fluidRow(
    column(6,
      box(
        title       = "🏆 Centrality Table",
        width       = NULL,
        solidHeader = TRUE,
        status      = "info",
        withSpinner(DTOutput("centrality_table"), color = "#CC0000", type = 4)
      )
    ),
    column(6,
      tabBox(
        title = "Centrality Plots",
        id    = "centrality_plot_tabs",
        width = NULL,
        tabPanel(
          title = "Weighted Degree",
          value = "cent_wdeg",
          icon  = icon("bar-chart"),
          withSpinner(plotOutput("centrality_wdeg_plot", height = "400px"), color = "#CC0000", type = 4)
        ),
        tabPanel(
          title = "Betweenness",
          value = "cent_between",
          icon  = icon("route"),
          withSpinner(plotOutput("centrality_between_plot", height = "400px"), color = "#CC0000", type = 4)
        )
      )
    )
  )
)
