network_server <- function(input, output, session, word_graph_rv) {

  output$network_properties <- renderUI({
    g <- word_graph_rv()
    n_nodes     <- igraph::vcount(g)
    n_edges     <- igraph::ecount(g)
    density     <- round(igraph::edge_density(g), 4)
    n_comp      <- igraph::components(g)$no
    avg_degree  <- round(mean(igraph::degree(g)), 2)
    transitivity <- round(igraph::transitivity(g, type = "global"), 3)

    tagList(
      tags$ul(
        tags$li(strong("Nodes (Words): "),      n_nodes),
        tags$li(strong("Edges (Co-occurrences): "), n_edges),
        tags$li(strong("Network Type: "),        "Undirected, Weighted"),
        tags$li(strong("Density: "),             density),
        tags$li(strong("Components: "),          n_comp),
        tags$li(strong("Avg. Degree: "),         avg_degree),
        tags$li(strong("Global Transitivity: "), transitivity)
      )
    )
  })

  output$graph_summary <- renderPrint({
    g <- word_graph_rv()
    print(g)
  })

  output$degree_dist_plot <- renderPlotly({
    g <- word_graph_rv()
    deg_df <- tibble(degree = igraph::degree(g))
    p <- ggplot(deg_df, aes(x = degree)) +
      geom_histogram(fill = "#CC0000", color = "white", binwidth = 1) +
      labs(
        title = "Degree Distribution",
        x     = "Degree (number of co-occurring words)",
        y     = "Number of Words"
      ) +
      theme_minimal(base_size = 12)
    ggplotly(p) %>% layout(showlegend = FALSE)
  })
}
