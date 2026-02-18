centrality_server <- function(input, output, session, rv) {
  
  # Degree centrality
  observeEvent(input$calc_degree, {
    req(rv$igraph)
    g <- rv$igraph
    
    if (input$degree_type == "normalized") {
      degree_scores <- igraph::degree(g, normalized = TRUE)
    } else {
      degree_scores <- igraph::degree(g)
    }
    
    rv$centrality_results$degree <- degree_scores
  })
  
  output$degree_top5 <- renderUI({
    req(rv$centrality_results$degree)
    
    scores <- rv$centrality_results$degree
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    top5_idx <- order(scores, decreasing = TRUE)[1:min(5, length(scores))]
    top5_names <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)
    
    items <- paste0(1:length(top5_names), ". ", top5_names, " (", top5_scores, ")")
    
    tags$ol(
      lapply(items, function(x) tags$li(HTML(gsub("^\\d+\\. ", "", x))))
    )
  })
  
  output$degree_centralization <- renderUI({
    req(rv$centrality_results$degree)
    
    cent <- igraph::centr_degree(rv$igraph)$centralization
    
    tagList(
      tags$ul(
        tags$li(strong("Centralization Score: "), round(cent, 3))
      ),
      p("Interpretation: Higher scores indicate the network is more centralized around a few key nodes.")
    )
  })
  
  output$degree_plot <- renderVisNetwork({
    req(rv$centrality_results$degree)
    req(rv$igraph)
    
    g <- rv$igraph
    scores <- rv$centrality_results$degree
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$value <- scores * 10
    vis_data$nodes$title <- paste("Degree:", round(scores, 3))
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$degree_dist <- renderPlotly({
    req(rv$centrality_results$degree)
    
    plot_ly(x = rv$centrality_results$degree, type = "histogram") %>%
      layout(
        title = "Degree Centrality Distribution",
        xaxis = list(title = "Degree Centrality"),
        yaxis = list(title = "Frequency")
      )
  })
  
  # Closeness, Betweenness, Eigenvector - similar patterns
  observeEvent(input$calc_closeness, {
    req(rv$igraph)
    rv$centrality_results$closeness <- closeness(rv$igraph, normalized = TRUE)
  })
  
  observeEvent(input$calc_betweenness, {
    req(rv$igraph)
    rv$centrality_results$betweenness <- betweenness(rv$igraph, normalized = TRUE)
  })
  
  observeEvent(input$calc_eigenvector, {
    req(rv$igraph)
    rv$centrality_results$eigenvector <- eigen_centrality(rv$igraph)$vector
  })
}