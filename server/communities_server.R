communities_server <- function(input, output, session, rv) {
  
  observeEvent(input$detect_communities, {
    req(rv$igraph)
    g <- rv$igraph
    
    communities <- switch(input$community_algorithm,
      "fastgreedy" = cluster_fast_greedy(as.undirected(g)),
      "louvain" = cluster_louvain(g),
      "walktrap" = cluster_walktrap(g),
      "edge_betweenness" = cluster_edge_betweenness(g),
      "label_prop" = cluster_label_prop(g),
      cluster_louvain(g)
    )
    
    rv$community_results <- communities
  })
  
  output$community_stats <- renderUI({
    req(rv$community_results)
    
    n_comm <- length(rv$community_results)
    sizes <- sizes(rv$community_results)
    modularity_score <- modularity(rv$community_results)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Communities: "), n_comm),
        tags$li(strong("Modularity Score: "), round(modularity_score, 3)),
        tags$li(strong("Community Sizes: "), paste(sizes, collapse = ", "))
      )
    )
  })
  
  output$community_plot <- renderVisNetwork({
    req(rv$community_results)
    req(rv$igraph)
    
    g <- rv$igraph
    membership <- membership(rv$community_results)
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    colors <- rainbow(max(membership))
    vis_data$nodes$color <- colors[membership]
    vis_data$nodes$group <- membership
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE) %>%
      visGroups(groupname = "community")
  })
}