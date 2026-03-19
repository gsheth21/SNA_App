bridges <- function(input, output, session, rv, g, components_result) {
  observeEvent(input$find_bridges_cutpoints, {
    req(rv$igraph)
    g <- g()
    g <- igraph::as.undirected(g)
    
    # Find bridges (articulation edges)
    bridges_list <- igraph::bridges(g)
    
    # Find cutpoints (articulation points)
    cutpoints_list <- igraph::articulation_points(g)
    
    rv$bridges_result <- bridges_list
    rv$cutpoints_result <- cutpoints_list
  })
  
  output$bridge_stats <- renderUI({
    req(rv$bridges_result)
    
    g <- g()
    n_bridges <- length(rv$bridges_result)
    n_edges <- igraph::ecount(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Bridges: "), n_bridges),
        tags$li(strong("Percentage of Edges: "), round(100 * n_bridges / n_edges, 1), "%"),
        tags$li(strong("Network Vulnerability: "), ifelse(n_bridges > n_edges * 0.1, "High", "Low"))
      )
    )
  })
  
  output$cutpoint_stats <- renderUI({
    req(rv$cutpoints_result)
    
    g <- g()
    n_cutpoints <- length(rv$cutpoints_result)
    n_nodes <- igraph::vcount(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Cutpoints: "), n_cutpoints),
        tags$li(strong("Percentage of Nodes: "), round(100 * n_cutpoints / n_nodes, 1), "%"),
        tags$li(strong("Network Fragility: "), ifelse(n_cutpoints > 0, "Fragile", "Robust"))
      )
    )
  })
  
  output$bridges_cutpoints_plot <- renderVisNetwork({
    req(rv$igraph, rv$bridges_result, rv$cutpoints_result)
    
    g <- g()
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Highlight cutpoints
    cutpoint_ids <- rv$cutpoints_result
    vis_data$nodes$color <- ifelse(1:igraph::vcount(g) %in% cutpoint_ids, "#FF0000", "#CCCCCC")
    vis_data$nodes$size <- input$node_size
    
    # Highlight bridges
    bridge_edges <- rv$bridges_result
    edge_ids <- igraph::get.edge.ids(g, t(igraph::as_edgelist(g)))
    vis_data$edges$color <- ifelse(edge_ids %in% bridge_edges, "#FF0000", "#000000")
    vis_data$edges$width <- ifelse(edge_ids %in% bridge_edges, 3, 1)
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$bridges_table <- renderDT({
    req(rv$igraph, rv$bridges_result)
    
    g <- g()
    bridges_ids <- rv$bridges_result
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    # Get edge endpoints
    edges <- igraph::as_edgelist(g)
    bridge_edges <- edges[bridges_ids, ]
    
    df <- data.frame(
      From = node_names[bridge_edges[, 1]],
      To = node_names[bridge_edges[, 2]]
    )
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$cutpoints_table <- renderDT({
    req(rv$igraph, rv$cutpoints_result)
    
    g <- g()
    cutpoint_ids <- rv$cutpoints_result
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    cutpoint_names <- node_names[cutpoint_ids]
    degrees <- igraph::degree(g)[cutpoint_ids]
    
    df <- data.frame(
      Node = cutpoint_names,
      Degree = degrees
    )
    
    df <- df[order(-df$Degree), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
}