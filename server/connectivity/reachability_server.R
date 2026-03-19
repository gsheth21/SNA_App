reachability <- function(input, output, session, rv, g, components_result) {
  output$reachability_node_select <- renderUI({
    req(rv$igraph)
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("reachability_node", "Select Source Node:", choices = node_names)
  })
  
  observeEvent(input$analyze_reachability, {
    req(rv$igraph, input$reachability_node)
    
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    node_id <- which(node_names == input$reachability_node)
    
    # Get all reachable nodes and their distances
    dist_from_node <- igraph::distances(g, v = node_id)[1, ]
    
    rv$reachability_result <- list(
      distances = dist_from_node,
      source_node = input$reachability_node,
      source_id = node_id
    )
  })
  
  output$reachability_stats <- renderUI({
    req(rv$reachability_result)
    
    dist <- rv$reachability_result$distances
    reachable <- sum(is.finite(dist)) - 1  # Exclude self
    total <- length(dist) - 1
    
    tagList(
      tags$ul(
        tags$li(strong("Source Node: "), rv$reachability_result$source_node),
        tags$li(strong("Reachable Nodes: "), reachable, " out of ", total),
        tags$li(strong("Reachability: "), round(100 * reachable / total, 1), "%"),
        tags$li(strong("Average Distance: "), round(mean(dist[is.finite(dist) & dist > 0]), 2))
      )
    )
  })
  
  output$reachable_by_distance <- renderPlotly({
    req(rv$reachability_result)
    
    dist <- rv$reachability_result$distances
    dist <- dist[dist > 0]
    dist <- dist[is.finite(dist)]
    
    dist_table <- table(dist)
    
    plot_ly(x = as.numeric(names(dist_table)), y = as.numeric(dist_table), type = "bar") %>%
      layout(
        title = "Nodes Reachable by Distance",
        xaxis = list(title = "Distance"),
        yaxis = list(title = "Number of Nodes")
      )
  })
  
  output$reachability_plot <- renderVisNetwork({
    req(rv$igraph, rv$reachability_result)
    
    g <- g()
    dist <- rv$reachability_result$distances
    source_id <- rv$reachability_result$source_id
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Color by reachability
    reachable <- is.finite(dist) & dist > 0
    vis_data$nodes$color <- ifelse(1:igraph::vcount(g) == source_id, "#FF0000",
                                    ifelse(reachable, "#00CC00", "#CCCCCC"))
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
}